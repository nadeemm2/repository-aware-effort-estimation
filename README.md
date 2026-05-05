# Repository-Aware Effort Estimation

This project investigates whether repository-aware issue metadata can improve agile story point estimation compared to using issue text alone.

We use the TAWOS dataset to build a story point prediction pipeline with two CodeBERT-based models:

1. **Text-only CodeBERT**  
   Uses only the issue title and natural-language description.

2. **Repository-aware CodeBERT**  
   Uses the same issue text, but augments it with project and issue metadata such as repository name, issue type, priority, components, affected versions, and whether the description contains code-like content.

Also tested against a LLM baseline using the Ollama LLaMa3 model locally one-shot prompting with using only issue descriptions.

## Motivation

Story point estimation is commonly used in agile software development, but it is subjective and often inconsistent across teams and projects. Prior work such as Deep-SE, GPT2SP, and Llama3SP mainly focuses on issue title and description text. This project explores whether adding repository-aware issue context helps the model make better effort predictions.

## Dataset

The project uses the TAWOS dataset, which contains issue data from open-source agile projects.

The filtered dataset keeps issues that:

- have non-null story point labels,
- have story points between 1 and 100,
- do not have story points changed after estimation.

The final dataset is split chronologically by issue creation date:

- 70% training,
- 10% validation,
- 20% testing.

This simulates a realistic setting where the model trains on historical issues and predicts future issues.

## Model

The prediction model is based on:

`microsoft/codebert-base`

CodeBERT is fine-tuned as a regression model with one output value representing the predicted story point.

## Evaluation Metrics

The main metric is:

MAE: Mean Absolute Error

We also report:

RMSE: Root Mean Squared Error
per-project MAE
story-point bucket error analysis

## Main Result

The repository-aware model improves over the text-only model on the held-out test set.

| Model | MAE | Improvement over Mean | Improvement over Median |
| -------- | -------- | -------- | -------- |
| Mean baseline | 3.9094 | -- | -- |
| Median baseline | 3.0832| 21.13% | -- |
| LLaMa3 baseline | 3.0308 | 22.47% | 1.7% |
| CodeBERT text-only | 2.6718 | 31.66% | 13.34% |
| CodeBERT repo-aware | 2.4798 | 36.57% | 19.57% |

The repository-aware model achieves a relative improvement of about 17.87% over the LLaMa3 model and 7.19% over the text-only CodeBERT baseline.

## Notes

This project avoids using obvious post-estimation signals such as comments, changelogs, pull requests, commits, changed files, and lines added/deleted in the main model. These features may be useful, but they can introduce data leakage because they are often only available after implementation.

Instead, the main experiment focuses on issue metadata that is generally available near issue creation or estimation time.

## Authors
- Nadeem Mohammed
- Ryan Muldoon

CS 527, University of Illinois Urbana-Champaign
