package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"

	"github.com/3n3a/gopentdb"
)

const (
	OUTPUT_FOLDER = "out"
)

func main()  {
	o := gopentdb.New(gopentdb.Config{
		BaseUrl: "https://opentdb.com",
	})

	// categories list
	categories, err := o.GetCategories()
	check(err)

	globalQuestions := make([]gopentdb.Question, 0)

	// Get Questions for each Category
	for _, category := range categories {
		questions := make([]gopentdb.Question, 0)

		token, err := o.GetSessionToken()
		check(err)

		count, err := o.GetCategoryCount(category.Id)
		check(err)

		remaining := count
	
		// Get Question Chunks of max 50 Questions for category
		for {
			questionChunk, err := o.GetQuestions(gopentdb.QuestionParams{
				Amount: remaining,
				Category: category.Id,
				Token: token,
			})
			check(err)
			
			fmt.Printf("Category %d - %s, Chunk Count %d\n", category.Id, category.Name, len(questionChunk))

			questions = append(questions, questionChunk...)
			remaining = remaining - int64(len(questionChunk))

			fmt.Printf("Questions Count %d of %d\n", len(questions), count)

			// Condition on which to halt getting Questions from Category
			if int64(len(questions)) == count {
				break
			}
		}

		globalQuestions = append(globalQuestions, questions...)

		SaveJson(questions, OUTPUT_FOLDER, fmt.Sprintf("%d-category.json", category.Id))
	}

	SaveJson(globalQuestions, OUTPUT_FOLDER, "all-questions.json")
}

// Save input in JSON-File
func SaveJson(input interface{}, folder string, filename string) {
	file, err := json.MarshalIndent(input, "", " ")
	check(err)
	err = ioutil.WriteFile(fmt.Sprintf("%s/%s.json", folder, filename), file, 0644)
	check(err)
	fmt.Printf("Saved Json in File: %s/%s.json\n", folder, filename)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}