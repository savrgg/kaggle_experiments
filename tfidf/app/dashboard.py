import plotly.graph_objects as go
import dash
import dash_html_components as html
import dash_core_components as dcc

class ArticleDashboard:
    def __init__(self, top_articles, similarity_scores):
        self.top_articles = top_articles
        self.similarity_scores = similarity_scores

    def create_bar_plot(self):
        bar_plot = go.Bar(
            x=list(range(len(self.similarity_scores))),
            y=self.similarity_scores,
            marker=dict(color="rgb(158,202,225)")
        )
        layout = go.Layout(
            title="Similarity Scores of Articles",
            xaxis=dict(title="Article Index"),
            yaxis=dict(title="Similarity Score"),
            showlegend=False
        )
        fig = go.Figure(data=[bar_plot], layout=layout)
        return fig

    def create_dashboard(self):
        app = dash.Dash(__name__)

        app.layout = html.Div([
            html.H1("Article Recommendation Dashboard"),
            html.H2("Top Article Recommendations:"),
            html.Ul([html.Li(article) for article in self.top_articles]),
            dcc.Graph(figure=self.create_bar_plot())
        ])

        app.run_server(debug=True)
