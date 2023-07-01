from clickup_api import ClickUpAPI
from exporter import Exporter

class Main:
    def __init__(self, config_file, excel_file):
        self.config_file = config_file
        self.excel_file = excel_file

    def run(self):
        api = ClickUpAPI(self.config_file)
        exporter = Exporter()
        exporter.export_tasks_to_excel(api, api.config['folder_id'], self.excel_file)


if __name__ == '__main__':
    config_file = 'config.json'
    excel_file = 'tasks.xlsx'

    main = Main(config_file, excel_file)
    main.run()