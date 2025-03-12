#!/bin/bash

# הגדרת משתנים
OUTPUT_DIR="$(pwd)/output_images/"  
IMAGE_5_2="python-runner"
NAME_5_2="5.2container"

IMAGE_5_3='java-runner'
NAME_5_3='5.3container'
# יצירת תיקיית פלט אם לא קיימת
mkdir -p "$OUTPUT_DIR"

# פונקציה להריץ את הקונטיינר של Python 5.2
run_container_python() {
    echo "🚀 Running Docker container: $IMAGE_5_2..."
    docker run -it --name "$NAME_5_2" "$IMAGE_5_2" --plant "Rose" --height 50 55 60 65 70 --leaf_count 35 40 45 50 55 --dry_weight 2.0 2.2 2.5 2.7 3.0
    if [ $? -ne 0 ]; then
        echo "❌ Failed to run Python Docker container. Exiting..."
        exit 1
    fi
    echo "✅ Python Docker container running!"
}

# פונקציה להריץ את הקונטיינר של Java 5.3
run_container_java() {
    echo "🚀 Running Docker container: $IMAGE_5_3..."
    
    # בונים את התמונה
    # docker build -t "$IMAGE_5_3" .
    # if [ $? -ne 0 ]; then
    #     echo "❌ Docker build failed. Exiting..."
    #     exit 1
    # fi

    # הרצת הקונטיינר עם שם
    # NAME_5_3="5.3container_java"
    docker run -it --name "$NAME_5_3" -v "$(pwd)":/app --entrypoint /bin/bash "$IMAGE_5_3" -c "javac Watermark.java && java Watermark /app 'Haim Hubara' 318688777"
    if [ $? -ne 0 ]; then
        echo "❌ Failed to run Java Docker container. Exiting..."
        exit 1
    fi
    echo "✅ Java Docker container running!"
}


# פונקציה להעתקת קבצים מהקונטיינר של Python
copy_files_from_container_python() {
    echo "📦 Copying files from the Python Docker container..."
    docker cp "$NAME_5_2:/app/Rose_scatter.png" "$OUTPUT_DIR/Rose_scatter.png"
    docker cp "$NAME_5_2:/app/Rose_histogram.png" "$OUTPUT_DIR/Rose_histogram.png"
    docker cp "$NAME_5_2:/app/Rose_line_plot.png" "$OUTPUT_DIR/Rose_line_plot.png"
    if [ $? -ne 0 ]; then
        echo "❌ Failed to copy files from Python container. Exiting..."
        exit 1
    fi
    echo "✅ Files copied successfully from Python container!"
}


# פונקציה לנקות את המשאבים
cleanup() {
    echo "🧹 Cleaning up..."
    
    # בדוק אם הקונטיינרים עדיין קיימים לפני שמוחקים
    if [ "$(docker ps -aq -f name=$NAME_5_2)" ]; then
        echo "Removing Python container ($NAME_5_2)..."
        docker rm -f "$NAME_5_2"
    else
        echo "Python container ($NAME_5_2) does not exist or is already removed."
    fi

    if [ "$(docker ps -aq -f name=$NAME_5_3)" ]; then
        echo "Removing Java container ($NAME_5_3)..."
        docker rm -f "$NAME_5_3"
    else
        echo "Java container ($NAME_5_3) does not exist or is already removed."
    fi
    
    echo "✅ Cleanup done!"
}


# שלבים
run_container_python
copy_files_from_container_python
run_container_java
cleanup