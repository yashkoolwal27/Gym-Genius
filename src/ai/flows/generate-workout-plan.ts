
'use server';

/**
 * @fileOverview An AI agent that generates a workout plan based on user input.
 *
 * - generateWorkoutPlan - A function that handles the workout plan generation process.
 * - GenerateWorkoutPlanInput - The input type for the generateWorkoutPlan function.
 * - GenerateWorkoutPlanOutput - The return type for the generateWorkoutPlan function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateWorkoutPlanInputSchema = z.object({
  fitnessLevel: z
    .enum(['Beginner', 'Intermediate', 'Advanced'])
    .describe("The user's fitness level."),
  goals: z.string().describe("The user's fitness goals (e.g., lose weight, build muscle)."),
  availableEquipment: z
    .string()
    .describe('The equipment available to the user (e.g., dumbbells, resistance bands, gym access).'),
  workoutDays: z
    .number()
    .min(1)
    .max(7)
    .describe('The number of days per week the user wants to workout.'),
  exerciseTypes: z
    .array(z.string())
    .describe('The types of workout the user prefers (e.g., Strength Training, Cardio, HIIT).'),
  workoutDate: z.string().describe('The date the user wants to start the workout plan.'),
  workoutTime: z.string().describe('The time of day the user wants to workout.'),
});

export type GenerateWorkoutPlanInput = z.infer<typeof GenerateWorkoutPlanInputSchema>;

const GenerateWorkoutPlanOutputSchema = z.object({
  workoutPlan: z.string().describe('The generated workout plan.'),
});

export type GenerateWorkoutPlanOutput = z.infer<typeof GenerateWorkoutPlanOutputSchema>;

export async function generateWorkoutPlan(input: GenerateWorkoutPlanInput): Promise<GenerateWorkoutPlanOutput> {
  return generateWorkoutPlanFlow(input);
}

const prompt = ai.definePrompt({
  name: 'generateWorkoutPlanPrompt',
  input: {schema: GenerateWorkoutPlanInputSchema},
  output: {schema: GenerateWorkoutPlanOutputSchema},
  prompt: `You are a personal trainer. Generate a detailed workout plan based on the following information:

Fitness Level: {{{fitnessLevel}}}
Goals: {{{goals}}}
Available Equipment: {{{availableEquipment}}}
Workout Days Per Week: {{{workoutDays}}}
Start Date: {{{workoutDate}}}
Preferred Time: {{{workoutTime}}}
Preferred Workout Types: {{#each exerciseTypes}}{{{this}}}{{#unless @last}}, {{/unless}}{{/each}}

The plan should be tailored to the start date and time if relevant (e.g., suggesting a lighter workout if it's early morning).
Provide the output as a structured plan, with clear headings for each workout day.
`,
});

const generateWorkoutPlanFlow = ai.defineFlow(
  {
    name: 'generateWorkoutPlanFlow',
    inputSchema: GenerateWorkoutPlanInputSchema,
    outputSchema: GenerateWorkoutPlanOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);
