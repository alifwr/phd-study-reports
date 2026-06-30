Training Reasoning Models with Reinforcement Learning

Executive Summary

This briefing document analyzes the methodologies for improving the reasoning performance of Large Language Models (LLMs) through reinforcement learning (RL). The primary shift identified is from Reinforcement Learning with Human Feedback (RLHF) to Reinforcement Learning with Verifiable Rewards (RLVR). While RLHF relies on expensive human annotations and additional reward models to align with preferences, RLVR utilizes deterministic, automatically verifiable signals (such as math correctness or code execution) to train reasoning capabilities.

A central focus of current development is the Group Relative Policy Optimization (GRPO) algorithm. Popularized by models like DeepSeek-R1, GRPO offers a resource-friendly alternative to traditional algorithms like Proximal Policy Optimization (PPO) by eliminating the need for a separate value model. Instead, it derives learning signals from relative performance comparisons within a group of sampled responses (rollouts). This approach effectively optimizes the model's behavior—shaping how it uses its pre-trained knowledge—to solve complex, multi-step reasoning tasks.

1. Core Training Paradigms: Scaling and Methods

1.1 Inference-Time vs. Training-Time Scaling

Reasoning performance and answer accuracy can be improved through two distinct compute investment strategies:

* Inference-Time Scaling: Increases accuracy by spending more computation per generated answer (e.g., advanced text generation and voting).
* Training-Time Scaling: Improves accuracy by investing additional computation during the training phase to modify model weights.

1.2 The Role of Reinforcement Learning (RL)

RL is typically applied as a post-training stage following pre-training and instruction fine-tuning.

* Pre-training: Primarily builds the model's knowledge base by training it to predict the next token.
* Reinforcement Learning: Shapes how the model uses its knowledge, specifically focusing on its reasoning behavior. It allows for the optimization of whole outputs (e.g., answer correctness) rather than individual tokens.

2. Comparison of RL Frameworks: RLHF vs. RLVR

The document distinguishes between two common RL stages used for LLMs:

Feature	RLHF (Preference Tuning)	RLVR (Reasoning Training)
Primary Goal	Aligning model outputs with human preferences.	Improving correctness on complex tasks (math, code).
Reward Signal	Human preference labels (subjective).	Verifiable rewards (deterministic/objective).
Reward Model	Requires training an additional LLM as a reward model.	Uses a deterministic verifier (e.g., a math verifier).
Complexity	High; requires human annotators and dual-model training.	Lower; collapses into a single training loop.
Scalability	Limited by human labeling effort and noise.	Scales naturally to large datasets without manual labels.

2.1 RLVR Practical Advantages

* Deterministic and Reproducible: Avoids the inconsistency inherent in human annotations.
* Domain Specificity: Particularly effective for domains with reliable verification signals, such as mathematics and programming.
* Resource Efficiency: Removes the cost of maintaining a separate reward model often comparable in size to the base LLM.

3. The GRPO Algorithm

Group Relative Policy Optimization (GRPO) is the preferred policy optimization algorithm for implementing RLVR in modern reasoning models.

3.1 GRPO vs. PPO

Traditional PPO requires a separate "value model" to estimate a value function, which increases computational overhead. GRPO is more resource-friendly because it derives its learning signal from relative comparisons within a group of sampled responses.

3.2 Technical Implementation (The Chef Analogy)

The mechanics of GRPO are illustrated through the analogy of a chef running a delivery service:

1. Prompt: A customer request (e.g., a request for lasagna).
2. Rollouts: The chef prepares several recipe variations for that single request.
3. Completions: The final dishes served to the customer.
4. Reward: The customer provides feedback after tasting the entire dish (whole-output evaluation).
5. Advantages: The chef compares the dishes relative to each other to identify which variations were superior.
6. Logprobs: The chef tracks how characteristic each dish was of their current "cooking style."
7. Policy Gradient Loss: The chef tweaks their style to reinforce successful choices.
8. KL Loss Term: The chef consults their original cookbook (reference model) to ensure the changes aren't too drastic (style-preservation).

3.3 Key Components of the GRPO Pipeline

1. Sampling Rollouts: The LLM generates multiple complete answers (rollouts) for a given prompt using temperature scaling and top-p sampling.
2. Calculating Rewards: A verifier (e.g., a math script) checks for final answer correctness. In reasoning tasks, binary rewards (1 for correct, 0 for incorrect) are common.
3. Computing Advantages: Advantages capture how a rollout performed relative to the group mean.
  * Formula: advantages_i = (r_i - μ_r) / (σ_r + ε)
  * Positive Advantage: Increases the likelihood of the actions that produced that rollout.
  * Negative Advantage: Decreases the likelihood.
4. Sequence Log-probabilities: Measures how likely the model considers the generated tokens under its current parameters. Unlike standard LLM training, GRPO often uses sequence-level logprobs because the reward applies to the entire response.
5. KL Regularization (Optional): A penalty term that prevents the updated model from drifting too far from the original pre-trained model. While part of the original formulation, some developers omit it to simplify implementation.

4. Implementation Foundations

4.1 Dataset Structure: The MATH Dataset

For reasoning training, the MATH dataset is utilized, consisting of approximately 12,500 problems.

* MATH-500: A 500-problem test set used for evaluation.
* MATH Training Set: A non-overlapping set of 12,000 problems used for RLVR.
* Key Fields: The "problem" field serves as the prompt, and the "answer" field is the ground truth for verification. The "solution" (step-by-step) is often ignored during training to allow the model to explore the solution space freely without being constrained to a specific style.

4.2 Reward Shaping and Constraints

Training often incorporates "implicit format constraints." For example, a model may only receive a reward of 1.0 if the answer is:

1. Correct (matches ground truth).
2. Formatted Properly (e.g., enclosed in \boxed{}).

This encourages the model to learn both the reasoning required for correctness and the adherence to specific output requirements. Research, such as that conducted by the DeepSeek-R1 team, suggests that training on final-answer correctness is more effective than attempting to use process reward models to score intermediate reasoning steps.

5. Critical Technical Insights

* Rollout Definition: In RL for LLMs, a "rollout" refers to the entire generation process for a prompt, while the "completion" is the resulting text.
* The "GR" in GRPO: Stands for "Group Relative," highlighting that the learning signal is constructed by comparing multiple answers to the same prompt.
* Base Model Training: Reasoning-focused RL can be applied directly to a pre-trained base model (skipping instruction tuning). While this may result in a weaker model overall, it allows researchers to isolate the specific effects of reasoning training.
* Inference Mode vs. Training Mode: When generating rollouts for training, developers must use @torch.no_grad instead of @inference_mode to ensure PyTorch remains compatible with the subsequent backward pass required for model weight updates.
