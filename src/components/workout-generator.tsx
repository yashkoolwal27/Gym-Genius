
"use client";

import { useState } from "react";
import { format } from "date-fns";
import { cn } from "@/lib/utils";
import { Clock, Dumbbell, Trash2, PlusCircle, CheckCircle, ChevronLeft } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Calendar } from "@/components/ui/calendar";
import { Checkbox } from "@/components/ui/checkbox";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutLog, LoggedExercise } from "@/lib/types";
import { Label } from "./ui/label";

const exerciseCategories = [
  { id: "chest", label: "Chest" },
  { id: "cardio", label: "Cardio" },
  { id: "arms", label: "Arms" },
  { id: "legs", label: "Legs" },
  { id: "core", label: "Core" },
  { id: "shoulders", label: "Shoulders" },
  { id: "back", label: "Back" },
] as const;

export function WorkoutGenerator() {
  const { toast } = useToast();
  const [loggedWorkouts, setLoggedWorkouts] = useLocalStorage<WorkoutLog[]>("workout-logs", []);
  
  const [step, setStep] = useState(1);
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [time, setTime] = useState<string>(format(new Date(), 'HH:mm'));
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [exercises, setExercises] = useState<LoggedExercise[]>([]);

  const addExercise = () => {
    setExercises([...exercises, { id: crypto.randomUUID(), name: "", sets: [{ id: crypto.randomUUID(), reps: "", weight: "" }] }]);
  };

  const removeExercise = (exerciseId: string) => {
    setExercises(exercises.filter(ex => ex.id !== exerciseId));
  };

  const updateExercise = (exerciseId: string, name: string) => {
    setExercises(exercises.map(ex => ex.id === exerciseId ? { ...ex, name } : ex));
  };

  const addSet = (exerciseId: string) => {
    setExercises(exercises.map(ex => {
      if (ex.id === exerciseId) {
        return { ...ex, sets: [...ex.sets, { id: crypto.randomUUID(), reps: "", weight: "" }] };
      }
      return ex;
    }));
  };

  const removeSet = (exerciseId: string, setId: string) => {
    setExercises(exercises.map(ex => {
      if (ex.id === exerciseId) {
        if (ex.sets.length > 1) {
          return { ...ex, sets: ex.sets.filter(set => set.id !== setId) };
        }
      }
      return ex;
    }));
  };

  const updateSet = (exerciseId: string, setId: string, field: 'reps' | 'weight', value: string) => {
    setExercises(exercises.map(ex => {
      if (ex.id === exerciseId) {
        return { ...ex, sets: ex.sets.map(set => set.id === setId ? { ...set, [field]: value } : set) };
      }
      return ex;
    }));
  };
  
  const handleCategoryChange = (categoryId: string, checked: boolean | 'indeterminate') => {
      setSelectedCategories(prev =>
          checked
              ? [...prev, categoryId]
              : prev.filter(id => id !== categoryId)
      );
  };

  const handleDateSelect = (selectedDate: Date | undefined) => {
    if (selectedDate) {
      setDate(selectedDate);
      setStep(2);
    }
  };

  const resetForm = () => {
    setDate(undefined);
    setTime(format(new Date(), 'HH:mm'));
    setSelectedCategories([]);
    setExercises([]);
    setStep(1);
  };

  const handleSubmit = () => {
    if (!date) {
        toast({
            variant: "destructive",
            title: "No Date Selected",
            description: "An unexpected error occurred. Please select the date again.",
        });
        return;
    }
    if (exercises.length === 0 || exercises.some(ex => !ex.name)) {
        toast({
            variant: "destructive",
            title: "Incomplete Workout",
            description: "Please add at least one exercise and give it a name.",
        });
        return;
    }

    const newLog: WorkoutLog = {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      date: date.toISOString(),
      time,
      exerciseTypes: selectedCategories,
      exercises,
    };
    
    setLoggedWorkouts([...loggedWorkouts, newLog]);

    toast({
        title: "Workout Logged!",
        description: "Your workout has been saved to 'My Progress'.",
    });

    resetForm();
  };
  
  if (step === 1) {
    return (
      <Card className="w-full flex-1 flex flex-col shadow-xl border-none bg-card/70">
        <CardHeader>
            <div className="flex justify-between items-center">
                <CardTitle className="text-2xl font-bold tracking-tight">Select a Date</CardTitle>
                <Button variant="link" className="p-0 text-primary">See Booked Slots &gt;</Button>
            </div>
        </CardHeader>
        <CardContent className="flex-1 flex justify-center items-center p-0 sm:p-6">
            <Calendar
                mode="single"
                selected={date}
                onSelect={handleDateSelect}
                className="w-full h-full flex flex-col"
                classNames={{
                    months: "flex flex-col sm:flex-row space-y-4 sm:space-x-4 sm:space-y-0 flex-1",
                    month: "flex flex-col flex-1",
                    table: "w-full border-collapse flex flex-col flex-1",
                    head_row: "flex justify-around",
                    row: "flex w-full mt-2 flex-1",
                    head_cell: "text-muted-foreground rounded-md flex-1 font-normal text-base",
                    cell: "p-0 relative text-center flex-1",
                    day: "w-full h-full text-base p-0 font-normal aria-selected:opacity-100 rounded-md",
                    day_selected: "bg-transparent text-accent border border-accent",
                    day_today: "bg-primary text-primary-foreground",
                }}
            />
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-8">
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
            <CardHeader>
                <div className="flex items-center gap-4">
                    <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => { setDate(undefined); setStep(1); }}>
                        <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <CardTitle className="flex items-center gap-2"><Dumbbell /> Log Your Workout</CardTitle>
                        <CardDescription>
                            Fill in the details for your session on {date ? format(date, "PPP") : 'the selected date'}.
                        </CardDescription>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="flex flex-col space-y-2">
                        <Label htmlFor="workout-time">Workout Time</Label>
                        <div className="relative">
                            <Clock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input id="workout-time" type="time" value={time} onChange={(e) => setTime(e.target.value)} className="pl-10" />
                        </div>
                    </div>
                </div>

                <div>
                  <Label>Exercise Categories</Label>
                   <div className="grid grid-cols-2 md:grid-cols-4 gap-4 pt-2">
                    {exerciseCategories.map((item) => (
                        <div key={item.id} className="flex flex-row items-center space-x-3 space-y-0">
                            <Checkbox
                                id={item.id}
                                checked={selectedCategories.includes(item.label)}
                                onCheckedChange={(checked) => handleCategoryChange(item.label, checked)}
                            />
                            <Label htmlFor={item.id} className="font-normal">{item.label}</Label>
                        </div>
                    ))}
                  </div>
                </div>
            </CardContent>
        </Card>
        
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70">
            <CardHeader>
                <CardTitle>Exercises</CardTitle>
                <CardDescription>Add the exercises you performed in this session.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
                {exercises.length === 0 && (
                    <div className="text-center text-muted-foreground py-8">
                        <p>No exercises added yet.</p>
                        <p className="text-sm">Click "Add Exercise" to get started.</p>
                    </div>
                )}
                {exercises.map((exercise, exIndex) => (
                    <Card key={exercise.id} className="p-4 bg-background relative">
                        <Button variant="ghost" size="icon" className="absolute top-2 right-2 h-7 w-7 text-muted-foreground hover:bg-destructive/10 hover:text-destructive" onClick={() => removeExercise(exercise.id)}>
                            <Trash2 className="h-4 w-4" />
                        </Button>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-start">
                            <div className="md:col-span-1 space-y-2">
                                <Label htmlFor={`ex-name-${exIndex}`}>Exercise Name</Label>
                                <Input id={`ex-name-${exIndex}`} placeholder="e.g. Bench Press" value={exercise.name} onChange={(e) => updateExercise(exercise.id, e.target.value)} />
                            </div>
                            <div className="md:col-span-2 space-y-2">
                                <div className="flex justify-between items-center text-sm font-medium">
                                    <Label>Sets</Label>
                                    <Button variant="outline" size="sm" onClick={() => addSet(exercise.id)}>
                                        <PlusCircle className="mr-2 h-4 w-4" /> Add Set
                                    </Button>
                                </div>
                                {exercise.sets.map((set, setIndex) => (
                                    <div key={set.id} className="flex gap-2 items-center">
                                        <span className="text-sm font-medium text-muted-foreground w-8 text-center">#{setIndex + 1}</span>
                                        <Input placeholder="Reps" value={set.reps} onChange={(e) => updateSet(exercise.id, set.id, 'reps', e.target.value)} />
                                        <Input placeholder="Weight (kg/lbs)" value={set.weight} onChange={(e) => updateSet(exercise.id, set.id, 'weight', e.target.value)} />
                                        <Button variant="ghost" size="icon" className="h-8 w-8 shrink-0 text-muted-foreground hover:bg-destructive/10 hover:text-destructive" onClick={() => removeSet(exercise.id, set.id)} disabled={exercise.sets.length <= 1}>
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </Card>
                ))}
                 <Button variant="secondary" className="w-full" onClick={addExercise}>
                    <PlusCircle className="mr-2 h-4 w-4" /> Add Exercise
                </Button>
            </CardContent>
            <CardFooter>
                 <Button onClick={handleSubmit} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground" disabled={exercises.length === 0}>
                    <CheckCircle className="mr-2 h-4 w-4" /> Log Workout
                </Button>
            </CardFooter>
        </Card>
    </div>
  );
}
