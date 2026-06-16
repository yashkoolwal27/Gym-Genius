
'use server';

/**
 * @fileOverview Meal plan generation flow.
 *
 * - generateMealPlan - A function that generates a meal plan based on user input.
 * - GenerateMealPlanInput - The input type for the generateMealPlan function.
 * - GenerateMealPlanOutput - The return type for the generateMealPlan function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateMealPlanInputSchema = z.object({
  dietaryRestrictions: z
    .string()
    .describe('Any dietary restrictions the user has (e.g., vegetarian, vegan, gluten-free).'),
  preferences: z
    .string()
    .describe('The users food preferences (e.g., likes chicken, dislikes beef).'),
  fitnessGoals: z
    .string()
    .describe('The users fitness goals (e.g., lose weight, gain muscle).'),
  numberOfMeals: z
    .number()
    .describe('The number of meals the user wants in the plan. Must be a number between 1 and 5 inclusive')
    .min(1)
    .max(5),
});

export type GenerateMealPlanInput = z.infer<typeof GenerateMealPlanInputSchema>;

const GenerateMealPlanFromHistoryInputSchema = z.object({
    pastMeals: z.array(z.string()).describe("A list of the user's recently logged meals."),
    fitnessGoals: z.string().describe("The user's current fitness goals (e.g., lose weight, gain muscle)."),
    numberOfMeals: z.number().min(1).max(5).describe("The number of meals for the new plan."),
});
export type GenerateMealPlanFromHistoryInput = z.infer<typeof GenerateMealPlanFromHistoryInputSchema>;


const GenerateMealPlanOutputSchema = z.object({
  mealPlan: z.string().describe('The generated meal plan.'),
});

export type GenerateMealPlanOutput = z.infer<typeof GenerateMealPlanOutputSchema>;

export async function generateMealPlan(input: GenerateMealPlanInput): Promise<GenerateMealPlanOutput> {
  return generateMealPlanFlow(input);
}

export async function generateMealPlanFromHistory(input: GenerateMealPlanFromHistoryInput): Promise<GenerateMealPlanOutput> {
    return generateMealPlanFromHistoryFlow(input);
}

const manualPrompt = ai.definePrompt({
  name: 'generateMealPlanPrompt',
  input: {schema: GenerateMealPlanInputSchema},
  output: {schema: GenerateMealPlanOutputSchema},
  prompt: `You are a personal nutritionist. Generate a meal plan for the user based on their dietary restrictions, preferences, and fitness goals.

  Dietary Restrictions: {{{dietaryRestrictions}}}
  Preferences: {{{preferences}}}
  Fitness Goals: {{{fitnessGoals}}}
  Number of Meals: {{{numberOfMeals}}}
  `,
});

const historyPrompt = ai.definePrompt({
  name: 'generateMealPlanFromHistoryPrompt',
  input: { schema: GenerateMealPlanFromHistoryInputSchema },
  output: { schema: GenerateMealPlanOutputSchema },
  prompt: `You are a personal nutritionist. A user wants a new meal plan based on their past meals.

Analyze the following meals they have logged:
{{#each pastMeals}}
- {{{this}}}
{{/each}}

Based on this history, identify their likely preferences and dietary habits.

Then, create a new, similar but varied meal plan for them that aligns with their stated fitness goal: "{{{fitnessGoals}}}".
The new plan should have {{{numberOfMeals}}} meals per day.
`,
});

const generateMealPlanFlow = ai.defineFlow(
  {
    name: 'generateMealPlanFlow',
    inputSchema: GenerateMealPlanInputSchema,
    outputSchema: GenerateMealPlanOutputSchema,
  },
  async input => {
    const {output} = await manualPrompt(input);
    return output!;
  }
);

const generateMealPlanFromHistoryFlow = ai.defineFlow(
    {
        name: 'generateMealPlanFromHistoryFlow',
        inputSchema: GenerateMealPlanFromHistoryInputSchema,
        outputSchema: GenerateMealPlanOutputSchema,
    },
    async (input) => {
        const { output } = await historyPrompt(input);
        return output!;
    }
);
