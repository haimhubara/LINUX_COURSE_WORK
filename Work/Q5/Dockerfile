FROM python:latest

WORKDIR /app

# העתקת קובץ הדרישות
COPY requirements.txt .

# התקנת כל התלויות
RUN pip install --no-cache-dir -r requirements.txt

# העתקת הקובץ הראשי
COPY plant_plots.py .

# הגדרת תיקייה שתשמור את הקבצים
VOLUME /app/plots

ENTRYPOINT [ "python", "plant_plots.py" ]
