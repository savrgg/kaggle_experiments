import requests

class NewsAPI:
    def __init__(self, api_key):
        self.api_key = api_key

    def get_articles(self, topic, num_articles):
        url = f"https://newsapi.org/v2/top-headlines"
        params = {
            "apiKey": self.api_key,
            "q": topic,
            "pageSize": num_articles
        }
        response = requests.get(url, params=params)
        data = response.json()
        articles = []
        for article in data["articles"]:
            title = article["title"]
            description = article["description"]
            if title and description:
                articles.append(title + " " + description)
        return articles
