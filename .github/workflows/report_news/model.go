package main

// News api
type Articles []struct {
	Author      string `json:"author"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Url         string `json:"url"`
	Image       string `json:"image"`
	Source      string `json:"source.name"`
	PublishedAt string `json:"publishedAt"`
}

type Response struct {
	Status       string   `json:"status"`
	TotalResults int      `json:"totalresults"`
	Articles     Articles `json:"articles"`
}

//TextOutput is exported,it formats the data to plain text.
func (resp Response) TextOutput(limit int) string {
	finalOutput := "\n"
	for index, article := range resp.Articles {

		finalOutput += "\n" + article.Title + "\n\n" + article.Description + "...\n> " + article.Url
		finalOutput += "\n-------------------------------------------\n"

		if index == limit {
			break
		}
	}

	return finalOutput
}
