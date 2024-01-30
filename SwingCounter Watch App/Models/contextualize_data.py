# Use this script to create a curation-ready CSV that includes context for each line of data.
#
# ARGUMENT - Pass in a SwingCounter motion data file
# RETURNS - This script returns a new CSV with additional columns of data context
# IMPORTANT - The first and last 10 data points (1 second) is ommitted from the returned CSV due to lack of context

import sys
import csv
import os


# FUNTCTION: Process Passed in File (Returns an array of the filtered data)
def process_csv(file_path):
    filtered_data_array = []

    try:
        with open(file_path, 'r') as csvfile:
            # Read CSV at given filepath
            reader = csv.DictReader(csvfile)

            # Filter each row in the CSV
            for row in reader:

                # Extract data from columns A, E, and I
                timestamp = row.get('Timestamp', '')
                accel_magnitude = row.get('Accel Magnitude', '')
                gyro_magnitude = row.get('Gyro Magnitude', '')

                # Append the filtered row to the array
                filtered_data = {
                    'Timestamp': timestamp,
                    'Accel Magnitude': accel_magnitude,
                    'Gyro Magnitude': gyro_magnitude
                }
                filtered_data_array.append(filtered_data)

    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")

    except Exception as e:
        print(f"An error occurred: {e}")
    
    return filtered_data_array


# FUNCTION: Add previous and next 10 data points (1 second) of context to passed in array (Returns a new array)
def contextualize(filtered_data_array):
    contextualized_data_array = []

    # Check if there are enough data points to process
    if len(filtered_data_array) < 21:
        print("Error: Insufficient data points in the CSV.")
        sys.exit(1)

    # Add context information to each item in the filtered_data_array (Omit first and last 10 data points)
    for i in range(10, len(filtered_data_array) - 10):
        current_data = filtered_data_array[i]

        # Initialize dictionaries for previous and next values
        previous_values = {}
        next_values = {}

        # Extract previous 10 'Accel Magnitude' and 'Gyro Magnitude' values
        for j, filtered_data in enumerate(filtered_data_array[i-10:i], start=1):
            previous_values[f'Accel -{round(1.1-j/10, 1)}s'] = filtered_data['Accel Magnitude']
            previous_values[f'Gyro -{round(1.1-j/10, 1)}s'] = filtered_data['Gyro Magnitude']

        # Extract next 10 'Accel Magnitude' and 'Gyro Magnitude' values
        for j, filtered_data in enumerate(filtered_data_array[i+1:i+11], start=1):
            next_values[f'Accel +{round(j/10, 1)}s'] = filtered_data['Accel Magnitude']
            next_values[f'Gyro +{round(j/10, 1)}s'] = filtered_data['Gyro Magnitude']

        # Combine all data into a new contextualized item with the desired column order
        contextualized_data = {
            'Timestamp': current_data['Timestamp'],
            **previous_values,
            'Current Accel': current_data['Accel Magnitude'],
            'Current Gyro': current_data['Gyro Magnitude'],
            **next_values
        }

        # Append the contextualized item to the array
        contextualized_data_array.append(contextualized_data)

    return contextualized_data_array


# FUNCTION: Write a new CSV with contextualized data
def export_to_csv(contextualized_data, input_csv_file):

    # Extract the directory, filename, and extension from the input CSV file path
    directory, filename = os.path.split(input_csv_file)
    filename, extension = os.path.splitext(filename)

    # Construct the output CSV file path in the same directory by appending "Contextualized_" to the filename
    output_csv_file = os.path.join(directory, f"Contextualized_{filename}.csv")

    # Specify the CSV header based on the keys in the contextualized_data dictionary
    csv_header = []
    for key in contextualized_data[0] :
        csv_header.append(key)

    try:
        with open(output_csv_file, 'w', newline='') as csvfile:
            # Create a CSV writer
            writer = csv.DictWriter(csvfile, fieldnames=csv_header)

            # Write the header
            writer.writeheader()

            # Write the data
            writer.writerows(contextualized_data)

        print(f"\nCSV exported successfully to {output_csv_file}\n")

    except Exception as e:
        print(f"Error exporting CSV: {e}")


# MAIN SCRIPT
if __name__ == "__main__":

    # 1. Check if the correct number of arguments (2) is provided
    if len(sys.argv) != 2:
        print("Usage: python3 script.py <csv_file>")
        sys.exit(1)

    # 2. Get the CSV file path from the command line argument
    input_csv_file = sys.argv[1]

    # 3. Call the function to process the CSV file
    filtered_data = process_csv(input_csv_file)
    
    # 4. Call the function to contextualize the filtered data
    contextualized_data = contextualize(filtered_data)

    # 5. Call the function to export the contextualized data to a new CSV file
    export_to_csv(contextualized_data, input_csv_file)