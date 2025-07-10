'use server';

/**
 * @fileOverview An AI agent that provides feedback on user's fitness data.
 *
 * - getAITrainerFeedback - A function that analyzes user data and provides feedback.
 * - GetAITrainerFeedbackInput - The input type for the function.
 * - GetAITrainerFeedbackOutput - The return type for the function.
 */

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const WorkoutSetSchema = z.object({
  id: z.string(),
  reps: z.string(),
  weight: z.string(),
});

const LoggedExerciseSchema = z.object({
  id: z.string(),
  name: z.string(),
  sets: z.array(WorkoutSetSchema),
});

const WorkoutLogSchema = z.object({
  id: z.string(),
  date: z.string(),
  time: z.string(),
  exerciseTypes: z.array(z.string()),
  exercises: z.array(LoggedExerciseSchema),
  createdAt: z.string(),
});

const MealLogSchema = z.object({
    id: z.string(),
    createdAt: z.string(),
    date: z.string(),
    mealType: z.string(),
    macronutrients: z.string(),
    fitnessGoals: z.string(),
    foodCategory: z.string(),
    mealDetails: z.string(),
});

const WeightLogSchema = z.object({
    id: z.string(),
    date: z.string(),
    weight: z.number(),
});

export const GetAITrainerFeedbackInputSchema = z.object({
  workoutLogs: z.array(WorkoutLogSchema).describe("The user's logged workouts."),
  mealLogs: z.array(MealLogSchema).describe("The user's logged meals."),
  weightLogs: z.array(WeightLogSchema).describe("The user's logged weights over time."),
});

export type GetAITrainerFeedbackInput = z.infer<typeof GetAITrainerFeedbackInputSchema>;

const GetAITrainerFeedbackOutputSchema = z.object({
  feedback: z.string().describe('The generated feedback and advice for the user in Markdown format. Use ### for main section titles and ** for sub-headings.'),
});

export type GetAITrainerFeedbackOutput = z.infer<typeof GetAITrainerFeedbackOutputSchema>;

export async function getAITrainerFeedback(input: GetAITrainerFeedbackInput): Promise<GetAITrainerFeedbackOutput> {
  return aiTrainerFlow(input);
}

const prompt = ai.definePrompt({
  name: 'aiTrainerPrompt',
  input: { schema: GetAITrainerFeedbackInputSchema },
  output: { schema: GetAITrainerFeedbackOutputSchema },
  prompt: `You are an expert AI Personal Trainer and Nutritionist named 'Gym Genius'. Your role is to provide a comprehensive, encouraging, and insightful analysis of the user's weekly fitness data. The user has provided you with their workout logs, meal logs, and weight logs.

Your task is to generate a personalized report in Markdown format. The report should have three main sections. Start each main section with '###' and each subsection with '**'.

1.  **### Workout Analysis**:
    *   **Consistency**: Comment on their workout frequency and consistency based on the logs.
    *   **Volume & Intensity**: Analyze the exercises, sets, reps, and weights. Note any signs of progressive overload or areas where they could push harder.
    *   **Variety**: Look at the variety of exercises and muscle groups targeted. Suggest new exercises if their routine seems monotonous.

2.  **### Nutrition Review**:
    *   **Dietary Patterns**: Analyze their meal logs. Identify their eating habits, common food choices, and meal timing.
    *   **Goal Alignment**: Comment on how well their logged meals (e.g., high-protein, low-carb) align with their stated fitness goals (e.g., muscle gain, fat loss).
    *   **Suggestions**: Offer 2-3 specific, actionable suggestions for improvement. For example, suggest healthier snack alternatives or ways to increase protein intake.

3.  **### Progress & Overall Feedback**:
    *   **Weight Trends**: Analyze the weight logs. Comment on their weight trend in relation to their goals.
    *   **Holistic View**: Provide an overall summary connecting their workouts, nutrition, and weight progress.
    *   **Motivational Tip**: End with a positive and motivational message to keep them engaged and inspired.

Here is the user's data:

**Workout Logs:**
{{#if workoutLogs}}
{{#each workoutLogs}}
- Date: {{date}}, Type: {{#each exerciseTypes}}{{{this}}}{{#unless @last}}, {{/unless}}{{/each}}
  {{#each exercises}}
  - Exercise: {{name}}
    {{#each sets}}
    - Set {{@index_1}}: {{reps}} reps at {{weight}}
    {{/each}}
  {{/each}}
{{/each}}
{{else}}
No workout data provided.
{{/if}}

**Meal Logs:**
{{#if mealLogs}}
{{#each mealLogs}}
- Date: {{date}}, Meal: {{mealType}} ({{macronutrients}}, for {{fitnessGoals}}), Details: {{mealDetails}}
{{/each}}
{{else}}
No meal data provided.
{{/if}}

**Weight Logs:**
{{#if weightLogs}}
{{#each weightLogs}}
- Date: {{date}}, Weight: {{weight}} lbs
{{/each}}
{{else}}
No weight data provided.
{{/if}}

Now, generate the personalized feedback report.
`,
});

const aiTrainerFlow = ai.defineFlow(
  {
    name: 'aiTrainerFlow',
    inputSchema: GetAITrainerFeedbackInputSchema,
    outputSchema: GetAITrainerFeedbackOutputSchema,
  },
  async (input) => {
    const { output } = await prompt(input);
    return output!;
  }
);
