import pandas as pd
import requests

class Exporter:
    @staticmethod
    def export_tasks_to_excel(api, folder_id, excel_file):
        # Get Lists in the Folder
        lists_url = f'{api.base_url}/folder/{folder_id}/list'
        response = requests.get(lists_url, headers=api.headers)

        if response.status_code == 200:
            lists = response.json()['lists']

            # Create a DataFrame to store all task data
            task_data = []

            for lst in lists:
                list_id = lst['id']
                list_name = lst['name']

                # Fetch tasks and subtasks from List
                tasks_url = f'{api.base_url}/list/{list_id}/task?subtasks=true&include_closed=true'
                response = requests.get(tasks_url, headers=api.headers)

                if response.status_code == 200:
                    tasks = response.json()['tasks']

                    # Process tasks and subtasks recursively
                    api.get_tasks_recursive(task_data, tasks)

                else:
                    print(f'Request failed with status code: {response.status_code}')
                    exit()

            # Create DataFrame from task_data
            df = pd.DataFrame(task_data, columns=[
                'List Name', 'Task ID', 'Task Name', 'Status', 'Due Date',
                'Start Date', 'Time Tracked', 'Time Estimate', 'Points', 'URL',
                'Description', 'Sprint Arkon', 'Assignee', 'Parent'
            ])

            # Join with the Sprint Arkon custom field options
            df_options = pd.DataFrame(api.get_custom_field_options(api.config['list_id'],
                                                                   api.config['custom_field_name']),
                                      columns=['id', 'label'])
            df = df.merge(df_options, left_on='Sprint Arkon', right_on='id', how='left')
            df.rename(columns={'label': 'Sprint Arkon Name'}, inplace=True)

            # Save DataFrame to Excel
            df.to_excel(excel_file, index=False)
            print(f'Tasks exported to {excel_file} successfully.')
        else:
            print(f'Request failed with status code: {response.status_code}')

