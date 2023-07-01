import json
import requests
import pandas as pd


class ClickUpAPI:
    def __init__(self, config_file):
        self.config = self.load_config(config_file)
        self.headers = {'Authorization': self.config['api_key']}
        self.base_url = 'https://api.clickup.com/api/v2'

    @staticmethod
    def load_config(config_file):
        with open(config_file, 'r') as file:
            return json.load(file)

    def get_custom_field_options(self, list_id, custom_field_name):
        custom_field_url = f'{self.base_url}/list/{list_id}/field'
        response = requests.get(custom_field_url, headers=self.headers)

        if response.status_code == 200:
            custom_fields = response.json()['fields']
            custom_field = next((cf for cf in custom_fields if cf['name'] == custom_field_name), None)
            if custom_field is None:
                print(f"Custom field '{custom_field_name}' not found.")
                exit()
            options = custom_field['type_config']['options']
            return options
        else:
            print(f'Request failed with status code: {response.status_code}')
            exit()


    def get_tasks_recursive(self, task_data, task_list, parent_name=None):
        for task in task_list:
            custom_fields = task['custom_fields']
            sprint_arkon_value = ''
            for cf in custom_fields:
                if cf['name'] == self.config['custom_field_name']:
                    if 'value' in cf and len(cf['value']) > 0:
                        sprint_arkon_value = cf['value'][0]
                    break

            task_data.append([
                task['list']['name'],
                task['id'],
                task['name'],
                task['status']['status'],
                task['due_date'],
                task['start_date'],
                task.get('time_tracked', 0),
                task['time_estimate'],
                task['points'],
                task['url'],
                task['description'],
                sprint_arkon_value,
                task['assignees'][0]['username'] if task['assignees'] else None,
                parent_name
            ])

            if 'subtasks' in task:
                self.get_tasks_recursive(task_data, task['subtasks'], parent_name=task['name'])

            if 'status' in task and task['status']['status'] == 'closed':
                self.get_tasks_recursive(task_data, [task['status']], parent_name=task['name'])
            
    def update_tasks_from_excel(self, excel_file):
        # Read the Excel file into a DataFrame
        df = pd.read_excel(excel_file)

        for _, row in df.iterrows():
            task_id = row['Task ID']
            task_name = row['Task Name']
            status = row['Status']
            due_date = row['Due Date']
            start_date = row['Start Date']
            time_estimate = row['Time Estimate']
            time_tracked = row['Time Tracked']
            points = row['Points']
            description = row['Description']
            sprint_arkon = row['Sprint Arkon']
            assignee = row['Assignee']

            # Construct the API endpoint URL for updating the task
            task_url = f"{self.base_url}/task/{task_id}"

            # Prepare the payload with the updated values
            payload = {
                'name': task_name,
                'status': status,
                'due_date': due_date,
                'start_date': start_date,
                'time_estimate': time_estimate,
                'time_tracked': time_tracked,
                'points': points,
                'description': description,
                'custom_fields': {
                    self.config['custom_field_name']: sprint_arkon
                },
                'assignees': assignee  # Can be a single assignee or a list of assignees
            }

            # Make a PUT request to update the task
            response = requests.put(task_url, headers=self.headers, json=payload)

            if response.status_code == 200:
                print(f"Task {task_id} updated successfully.")
            else:
                print(f"Failed to update task {task_id}. Error: {response.text}")