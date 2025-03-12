#!/bin/bash

CSV_FILE=""

function create_csv() {
    echo "Enter CSV filename:"
    read filename
    CSV_FILE="$filename.csv"
    echo "Plant,Height,Leaf Count,Dry Weight" > $CSV_FILE
    echo "File $CSV_FILE created."
}

function select_csv() {
    echo "Enter existing CSV filename:"
    read filename
    if [ -f "$filename" ]; then
        CSV_FILE="$filename"
        echo "File $CSV_FILE selected."
    else
        echo "File not found!"
    fi
}

function show_csv() {
    if [ -f "$CSV_FILE" ]; then
        cat "$CSV_FILE"
    else
        echo "No file selected!"
    fi
}

function add_row() {
    echo "Enter Plant Name:"
    read plant
    echo "Enter Heights (comma-separated):"
    read heights
    echo "Enter Leaf Count (comma-separated):"
    read leafs
    echo "Enter Dry Weight (comma-separated):"
    read weight
    echo "$plant,\"$heights\",\"$leafs\",\"$weight\"" >> $CSV_FILE
    echo "Row added."
}


function show_highest_average_leafs() {
    if [ -f "$CSV_FILE" ]; then
        highest_avg=0
        highest_plant=""

        while IFS=',' read -r plant heights leafs weight; do
            # Skip the header line
            if [ "$plant" != "Plant" ]; then
                # Convert leafs to an array
                IFS='-' read -ra leafs_array <<< "$leafs"
                total_leaves=0
                count=0
                for leaf in "${leafs_array[@]}"; do
                    # Ensure leaf count is a valid integer
                    if [[ "$leaf" =~ ^[0-9]+$ ]]; then
                        total_leaves=$((total_leaves + leaf))
                        count=$((count + 1))
                    fi
                done
                
                if [ $count -gt 0 ]; then
                    avg_leaf_count=$((total_leaves / count))
                else
                    avg_leaf_count=0
                fi

                # Check if this plant has the highest average leaf count
                if [ "$avg_leaf_count" -gt "$highest_avg" ]; then
                    highest_avg=$avg_leaf_count
                    highest_plant=$plant
                fi
            fi
        done < $CSV_FILE

        if [ -z "$highest_plant" ]; then
            echo "No data available!"
        else
            echo "The plant with the highest average leaf count is: $highest_plant with an average of $highest_avg leaves."
        fi
    else
        echo "No file selected!"
    fi
}


function delete_row() {
    if [ -z "$CSV_FILE" ]; then
        echo "No file selected!"
        return
    fi
    
    echo "Enter Plant Name to Delete:"
    read plant
    plant=$(echo "$plant" | xargs)  

    if [ -f "$CSV_FILE" ]; then
        temp_file=$(mktemp)
        found=false
        first_line=true 
        
        while IFS=',' read -r name heights leafs weight; do
           
            if $first_line; then
                first_line=false
                echo "$name,$heights,$leafs,$weight" >> $temp_file
                continue
            fi

            
            name=$(echo "$name" | xargs | sed 's/^"\(.*\)"$/\1/') 

          
            echo "Comparing '$name' to '$plant'"

           
            if [ -n "$name" ]; then
                if [ "$name" != "$plant" ]; then
                    echo "$name,$heights,$leafs,$weight" >> $temp_file
                else
                    found=true
                fi
            fi
        done < "$CSV_FILE"
        
        if [ "$found" = false ]; then
            echo "Plant not found!"
        else
            mv $temp_file $CSV_FILE
            echo "Row deleted."
        fi
    else
        echo "No file selected!"
    fi
}
function update_row() {
    if [ -z "$CSV_FILE" ]; then
        echo "No file selected!"
        return
    fi

    echo "Enter Plant Name to Update:"
    read plant
    plant=$(echo "$plant" | xargs)  

   
    echo "Enter Heights (comma-separated):"
    read heights
    echo "Enter Leaf Count (comma-separated):"
    read leafs
    echo "Enter Dry Weight (comma-separated):"
    read weight

    if [ -f "$CSV_FILE" ]; then
        temp_file=$(mktemp)
        found=false
        first_line=true  
        
        while IFS=',' read -r name height leaf weight_in_file; do
           
            if $first_line; then
                first_line=false
                echo "$name,$height,$leaf,$weight_in_file" >> $temp_file
                continue
            fi

           
            name=$(echo "$name" | xargs | sed 's/^"\(.*\)"$/\1/') 

            if [ -n "$name" ]; then
                if [ "$name" != "$plant" ]; then
                   
                    echo "$name,$height,$leaf,$weight_in_file" >> $temp_file
                else
                  
                    found=true
                    echo "$name,\"$heights\",\"$leafs\",\"$weight\"" >> $temp_file
                fi
            fi
        done < "$CSV_FILE"

        if [ "$found" = false ]; then
            echo "Plant not found!"
        else
            mv $temp_file $CSV_FILE
            echo "Row Updated."
        fi
    else
        echo "No file selected!"
    fi
}








function generate_plots() {
    if [ -f "$CSV_FILE" ]; then
        echo "Enter Plant Name:"
        read plant
        
      
        plant_data=$(awk -F',' -v plant="$plant" '$1 == plant {print $2, $3, $4}' $CSV_FILE)
        
        if [ -z "$plant_data" ]; then
            echo "Plant not found!"
            return
        fi
        
       
        heights=$(echo $plant_data | cut -d' ' -f1)
        leaf_count=$(echo $plant_data | cut -d' ' -f2)
        dry_weight=$(echo $plant_data | cut -d' ' -f3)
        
      
        heights=$(echo $heights | tr -d '"')
        leaf_count=$(echo $leaf_count | tr -d '"')
        dry_weight=$(echo $dry_weight | tr -d '"')

        heights=$(echo $heights | tr "-" " " | tr "," " ")
        leaf_count=$(echo $leaf_count | tr "-" " " | tr "," " ")
        dry_weight=$(echo $dry_weight | tr "-" " " | tr "," " ")

      
        python Work/Q2/plant_plots.py --plant "$plant" --height $heights --leaf_count $leaf_count --dry_weight $dry_weight
    else
        echo "No file selected!"
    fi
}





function menu() {
    while true; do
        echo "1. Create CSV"
        echo "2. Select CSV"
        echo "3. Show CSV"
        echo "4. Add Row"
        echo "5. Generate Plots for Plant"
        echo "6. Update Row by Plant Name"
        echo "7. Delete Row by Plant Name"
        echo "8. Show the plant with the highest average leaf count"
        echo "9. Exit"
        read -p "Choose an option: " option
        case $option in
            1) create_csv ;;
            2) select_csv ;;
            3) show_csv ;;
            4) add_row ;;
            5) generate_plots ;;
            6) update_row ;;
            7) delete_row ;;
            8) show_highest_average_leafs ;;
            9) exit 0 ;;
            *) echo "Invalid option" ;;
        esac
    done
}

menu
