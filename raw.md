Distilling Reasoning Models for Efficient Artificial Intelligence

This briefing document provides a comprehensive analysis of model distillation techniques used to create efficient reasoning models. It synthesizes technical methodologies, performance benchmarks, and implementation strategies derived from the provided documentation.

Executive Summary

Model distillation is a training-time technique where a smaller "student" model is trained to replicate the outputs—specifically the reasoning traces and final answers—of a much larger "teacher" model. This approach addresses the high computational and financial barriers associated with massive reasoning models like the 671-billion-parameter DeepSeek-R1.

Critical Takeaways:

* Efficiency Gains: Distillation training is significantly faster and less resource-intensive than Reinforcement Learning from Verifiable Rewards (RLVR). In documented setups, distillation required only ~3 hours and 15 GB of RAM, compared to 12 hours and 70 GB for RLVR.
* Superior Performance: Small models trained through distillation often outperform comparable models trained via reinforcement learning alone.
* Practicality: "Hard distillation," which uses only the teacher’s text outputs rather than complex probability distributions (logits), is the most common and practical method for Large Language Model (LLM) development.
* Data Quality: The effectiveness of the student model is fundamentally tied to the quality of the teacher’s reasoning traces. High-performing teachers (e.g., DeepSeek-R1 with ~91% accuracy) provide the necessary supervision for the student to improve beyond its base capabilities.

1. Foundational Concepts of Model Distillation

Model distillation serves as a method to scale down the capabilities of massive systems into formats that can be deployed on local hardware or less expensive infrastructure.

1.1 The Teacher-Student Dynamic

* Teacher Model: A large, high-performance LLM (e.g., DeepSeek-R1) that generates "supervision" data.
* Student Model: A smaller LLM (e.g., Qwen3 0.6B) that is fine-tuned to reproduce the teacher's reasoning path and final conclusion.

1.2 Comparison of Distillation Types

The documents identify three primary approaches to distillation, summarized in the table below:

Distillation Type	Training Target	Requirements	Practicality for LLMs
Hard Distillation	Teacher-generated text tokens.	Access to text outputs only.	High: Standard for LLMs; compatible with proprietary APIs.
Soft Distillation	Teacher's full probability distribution (logits).	Access to teacher logits and identical tokenizers.	Low: Computationally expensive; logits are often hidden by providers.
Combined	Both text tokens and probability distributions.	Full model access (Teacher + Student).	Medium: Common in computer vision; rarer in LLM distillation.

2. Dataset Generation and Preparation

The success of distillation depends on the creation of a high-quality synthetic dataset consisting of complex reasoning tasks.

2.1 Synthetic Data Generation

The documented process utilized 12,000 math problems from the Mathematics Aptitude Test of Heuristics (MATH) dataset.

* Source: Problems were processed by DeepSeek-R1 to generate reasoning traces.
* Cost Efficiency: Using an API (OpenRouter) to generate 12,000 solutions cost approximately $50, which is significantly lower than the cost of training a massive model from scratch.
* Performance Baseline: DeepSeek-R1 achieved 90.6% accuracy on the training set and 91.2% on the MATH-500 test set, providing a high-quality target for the student model.

2.2 Formatting for Reasoning

To facilitate clear parsing, reasoning traces are typically enclosed in <think>...</think> tags. This serves several purposes:

* User Interface Control: Allows applications to hide verbose reasoning while showing the final answer.
* Consistent Formatting: Helps the model learn a clear boundary between internal "thought" and the final output.
* Standardization: Aligns the training with modern reasoning model conventions (e.g., Qwen3 and ChatGPT).

3. Preprocessing and Building Training Examples

Before training, raw text must be converted into a structured format suitable for the model’s tokenizer.

3.1 Tokenization Pipeline

The process follows a three-stage pipeline for each sample:

1. Prompt Rendering: The math problem is formatted into a chat prompt (e.g., using <|im_start|>user tags).
2. Answer Formatting: The teacher's reasoning trace and final answer are combined into a single target string.
3. Concatenation: The prompt and answer are joined into a single token sequence ending with an end-of-sequence (<|im_end|>) token.

3.2 Filtering and Sequence Management

Reasoning traces can be excessively long, which increases computational requirements.

* Average Length: The initial dataset averaged 2,946 tokens per response.
* Outliers: Some traces reached up to 42,005 tokens.
* Filtering Strategy: To keep costs reasonable and fit within hardware constraints, the dataset was filtered to a maximum length of 2,048 tokens. This removed 5,305 of the original 12,000 examples, resulting in a training set of 6,695 high-quality examples.

4. Distillation Training Methodology

Distillation is implemented as a supervised fine-tuning task using cross-entropy loss.

4.1 Cross-Entropy and Log-Probabilities

Training focuses on Next-Token Prediction. The model is penalized based on how much probability it assigns to the "correct" token (the one generated by the teacher).

* Log-Probability: Measures the model's confidence in the correct next token.
* Cross-Entropy Loss: The negative average of these token log-probabilities. A value closer to 0 indicates the student is highly confident in the teacher's reasoning path.

4.2 Answer-Only Loss

A critical technical detail in distillation is the use of Answer-Only Loss.

* Mechanism: The loss is computed only on the tokens generated by the teacher, not the tokens in the prompt.
* Logic: The model's task is to generate the answer conditioned on the prompt. Penalizing the model for reproducing the prompt tokens (which are already provided as input) is counterproductive.

4.3 The Training Loop

Distillation training iterates over the dataset for multiple epochs.

* Epoch: One complete pass through the training data. Shuffling the data each epoch helps the model generalize.
* Metrics: Progress is tracked via Training Loss (measured on optimized samples) and Validation Loss (measured on a held-out set). Validation loss is the more reliable metric for assessing whether the student's improvements will generalize to new problems.

5. Performance Metrics and Benchmarking

The effectiveness of the distillation process is measured by comparing the student's accuracy against various baselines on the MATH-500 test set.

Model / Configuration	MATH-500 Accuracy
DeepSeek-R1 (Teacher)	91.2%
Qwen3 0.6B (Reasoning Reference)	50.8%
Qwen3 0.6B (Base Model - Pre-distillation)	15.2%

The data confirms that the base model (15.2% accuracy) requires significant training to reach the reasoning standards established by the teacher or the official reasoning-tuned variants. Distillation provides a more direct and efficient path to this improvement than traditional reinforcement learning from scratch.
