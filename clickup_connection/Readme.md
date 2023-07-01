# ClickUp Task Exporter

This repository contains a Python script that allows you to export tasks from ClickUp, a project management platform, to an Excel file. The exported tasks can be further analyzed, manipulated, or shared with others.

## Prerequisites
Before running the script, ensure that you have the following:

- Python 3.x installed on your machine
- Required Python packages: `pandas` and `requests`. You can install them by running `pip install pandas requests`
- ClickUp API key: Obtain an API key from ClickUp by following their documentation on API authentication.
- ClickUp configuration file: Create a JSON configuration file (`config.json`) containing your ClickUp API key and other necessary details. Refer to the `config.jsonexample` file for the required structure.

## Getting Started

1. Clone this repository to your local machine or download the ZIP file and extract its contents.

2. Install the required Python packages by running the following command:

`pip install -r requirements.txt`

This command will install the necessary packages (`pandas` and `requests`) specified in the `requirements.txt` file.

3. Obtain a ClickUp API key by following the ClickUp documentation on API authentication.

4. Create a `config.json` file based on the provided config.`config.jsonexample` file. Fill in your ClickUp API key and other required details.

5. Run the script by executing the `main.py` file:

`python main.py`

6. The script will export the tasks from ClickUp to an Excel file named `tasks.xlsx`

## Script Overview
- `clickup_api.py`: Contains the ClickUpAPI class, which handles the ClickUp API communication, including authentication, fetching task data, and updating tasks based on an Excel file.
- `exporter.py`: Contains the `Exporter` class, which exports tasks to an Excel file using the ClickUp API.

- `main.py`: Contains the `Main` class, which acts as the entry point for running the script. It creates instances of the `ClickUpAPI` and `Exporter` classes to export tasks from ClickUp.

## Customization
- You can modify the columns exported to the Excel file by editing the `columns` list in the `export_tasks_to_excel` method of the `Exporter` class in `exporter.py`.

- If you want to update tasks in ClickUp based on an Excel file, you can use the `update_tasks_from_excel` method of the `ClickUpAPI` class in `clickup_api.py`. This method reads the Excel file and updates the corresponding tasks in ClickUp.

## Limitations
- This script assumes that you have appropriate access and permissions to the ClickUp workspace, folder, and lists specified in the configuration file.

- The script currently supports exporting tasks from ClickUp to an Excel file and updating tasks in ClickUp based on an Excel file. Other ClickUp functionalities are not implemented.

## License
This project is licensed under the MIT License. Feel free to modify and use it according to your needs.

## Acknowledgments
This script was developed using the ClickUp API and the Python programming language. Special thanks to the developers of ClickUp for providing the API and documentation.
