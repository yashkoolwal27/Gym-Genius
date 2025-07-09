
"use client";

import { useState, useEffect, useRef } from "react";
import Image from "next/image";
import Link from "next/link";
import { format } from "date-fns";
import { formatInTimeZone } from "date-fns-tz";
import { cn } from "@/lib/utils";
import { Clock, Dumbbell, Trash2, PlusCircle, CheckCircle, ChevronLeft, ChevronRight } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Calendar } from "@/components/ui/calendar";
import { useToast } from "@/hooks/use-toast";
import { useLocalStorage } from "@/hooks/use-local-storage";
import type { WorkoutLog, LoggedExercise, Exercise } from "@/lib/types";
import { Label } from "./ui/label";
import { exerciseData, isSubCategory, isExerciseList } from "@/lib/exercises";
import { ScrollArea } from "./ui/scroll-area";

const initialExerciseCategories = [
  { id: "chest", label: "Chest", image: "https://images.unsplash.com/photo-1739991892140-eab6fe4700d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw3fHxjaGVzdCUyMHByZXNzfGVufDB8fHx8MTc1MjA2MDcyMHww&ixlib=rb-4.1.0&q=80&w=1080", hint: "chest press" },
  { id: "cardio", label: "Cardio", image: "https://images.unsplash.com/photo-1669806954505-936e77929af6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHwyfHx0cmVhZG1pbGwlMjBydW5uaW5nfGVufDB8fHx8MTc1MjA2MDcyMHww&ixlib=rb-4.1.0&q=80&w=1080", hint: "treadmill running" },
  { id: "biceps", label: "Biceps", image: "https://images.unsplash.com/photo-1605180427725-95e306fc0e9a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw4fHxiaWNlcCUyMGN1cmx8ZW58MHx8fHwxNzUyMDYwNzIwfDA&ixlib=rb-4.1.0&q=80&w=1080", hint: "bicep curl" },
  { id: "triceps", label: "Triceps", image: "https://images.unsplash.com/photo-1672209962122-4e38cd353163?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw2fHx0cmljZXAlMjBkaXB8ZW58MHx8fHwxNzUyMDYwNzIwfDA&ixlib=rb-4.1.0&q=80&w=1080", hint: "tricep dip" },
  { id: "forearms", label: "Forearms", image: "https://images.unsplash.com/photo-1674834726923-3ba828d37846?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHwxMHx8Zm9yZWFybXMlMjBleGVyY2llc3xlbnwwfHx8fDE3NTIwOTY3NDN8MA&ixlib=rb-4.1.0&q=80&w=1080", hint: "forearms exercise" },
  { id: "legs", label: "Legs", image: "https://images.unsplash.com/photo-1662045010188-b5e91a7f504b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw2fHxzcXVhdCUyMHdvcmtvdXR8ZW58MHx8fHwxNzUyMDYwNzIxfDA&ixlib=rb-4.1.0&q=80&w=1080", hint: "squat workout" },
  { id: "abs", label: "Abs", image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHwxfHxhYnMlMjB3b3Jrb3V0fGVufDB8fHx8MTc1MzA0NDc1OXww&ixlib=rb-4.1.0&q=80&w=1080", hint: "abs workout" },
  { id: "shoulders", label: "Shoulders", image: "https://images.unsplash.com/photo-1745508201242-6495edf95b99?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw2fHxzaG91bGRlciUyMHByZXNzfGVufDB8fHx8MTc1MjA2MDcyMHww&ixlib=rb-4.1.0&q=80&w=1080", hint: "shoulder press" },
  { id: "back", label: "Back", image: "https://images.unsplash.com/photo-1597452494947-f2986526d1be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHw4fHxwdWxsJTIwdXB8ZW58MHx8fHwxNzUyMDYwNzIwfDA&ixlib=rb-4.1.0&q=80&w=1080", hint: "pull up" },
] as const;

export function WorkoutGenerator() {
  const { toast } = useToast();
  const [loggedWorkouts, setLoggedWorkouts] = useLocalStorage<WorkoutLog[]>("workout-logs", []);
  
  const [step, setStep] = useState(1);
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [time, setTime] = useState<string>(format(new Date(), 'HH:mm'));
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [exercises, setExercises] = useState<LoggedExercise[]>([]);
  const [today, setToday] = useState<Date | undefined>(undefined);
  const timeInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    // Set "today" based on Indian Standard Time. This ensures future dates
    // are disabled correctly regardless of the user's local timezone.
    const todayStrInIndia = formatInTimeZone(new Date(), 'Asia/Kolkata', 'yyyy-MM-dd');
    setToday(new Date(todayStrInIndia));
  }, []);

  const handleDateSelect = (selectedDate: Date | undefined) => {
    setDate(selectedDate);
    if (selectedDate) {
      setTimeout(() => {
        timeInputRef.current?.focus();
      }, 0);
    }
  };

  const toggleExercise = (name: string) => {
    setExercises(prev => {
        const isAdded = prev.some(ex => ex.name === name);
        if (isAdded) {
            return prev.filter(ex => ex.name !== name);
        } else {
            return [...prev, { id: crypto.randomUUID(), name, sets: [{ id: crypto.randomUUID(), reps: "", weight: "" }] }];
        }
    });
  };

  const removeExercise = (exerciseId: string) => {
    setExercises(exercises.filter(ex => ex.id !== exerciseId));
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
  
  const handleCategoryChange = (categoryId: string, checked: boolean) => {
      setSelectedCategories(prev =>
          checked
              ? [...prev, categoryId]
              : prev.filter(id => id !== categoryId)
      );
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
    if (exercises.length === 0) {
        toast({
            variant: "destructive",
            title: "No Exercises Logged",
            description: "Please add at least one exercise to your log.",
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
                <CardTitle className="text-2xl font-bold tracking-tight">Select Date &amp; Time</CardTitle>
                <Button variant="link" className="p-0 text-primary" asChild>
                  <Link href="/progress-tracker">See Logged Workouts</Link>
                </Button>
            </div>
        </CardHeader>
        <CardContent className="flex-1 flex justify-center items-center p-0 sm:p-6">
            <Calendar
                mode="single"
                selected={date}
                onSelect={handleDateSelect}
                disabled={{ after: today }}
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
                    day_selected: "bg-primary text-primary-foreground hover:bg-primary/90 focus:bg-primary/90",
                    day_today: "bg-accent text-accent-foreground",
                    day_disabled: "text-muted-foreground/50 cursor-not-allowed",
                }}
            />
        </CardContent>
        <CardFooter className="flex-col sm:flex-row items-center gap-4 border-t pt-6 transition-all duration-300 min-h-[98px] sm:min-h-[82px]">
          {date ? (
            <>
              <div className="flex-1 w-full sm:w-auto">
                  <Label htmlFor="workout-time">Workout Time</Label>
                  <div className="relative mt-2">
                      <Clock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <Input ref={timeInputRef} id="workout-time" type="time" value={time} onChange={(e) => setTime(e.target.value)} className="pl-10" />
                  </div>
              </div>
              <Button onClick={() => setStep(2)} disabled={!date} className="w-full sm:w-auto mt-4 sm:mt-0" size="lg">
                  Next Step
                  <ChevronRight className="ml-2 h-4 w-4" />
              </Button>
            </>
          ) : (
            <div className="flex w-full justify-center items-center">
                <p className="text-muted-foreground">Select a date to set the time.</p>
            </div>
          )}
        </CardFooter>
      </Card>
    );
  }

  if (step === 2) {
    return (
        <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70 flex-1 flex flex-col">
            <CardHeader>
                <div className="flex items-center gap-4">
                    <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(1)}>
                        <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <CardTitle className="flex items-center gap-2"><Dumbbell /> Log Your Workout</CardTitle>
                        <CardDescription>
                            Select muscle groups for your session on {date ? format(date, "PPP") : 'the selected date'} at {time}.
                        </CardDescription>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="flex-1">
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 pt-4">
                {initialExerciseCategories.map((item) => {
                  const isSelected = selectedCategories.includes(item.label);
                  return (
                    <div
                      key={item.id}
                      onClick={() => handleCategoryChange(item.label, !isSelected)}
                      className={cn(
                        "rounded-lg cursor-pointer group border-2 p-2 text-center space-y-2 transition-all",
                        isSelected
                          ? "border-primary bg-primary/5"
                          : "border-transparent bg-muted/50 hover:bg-muted/100"
                      )}
                    >
                      <div className="aspect-square w-full relative overflow-hidden rounded-md">
                        <Image
                          src={item.image}
                          alt={item.label}
                          width={200}
                          height={200}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          data-ai-hint={item.hint}
                        />
                      </div>
                      <h3 className="font-medium text-sm text-foreground">{item.label}</h3>
                    </div>
                  );
                })}
              </div>
            </CardContent>
            <CardFooter>
                 <Button onClick={() => setStep(3)} className="w-full" size="lg" disabled={selectedCategories.length === 0}>
                    Next Step <ChevronRight className="ml-2 h-4 w-4" />
                </Button>
            </CardFooter>
        </Card>
    );
  }

  if (step === 3) {
    const renderExercises = (exerciseList: readonly Exercise[], subCategoryName?: string) => (
      <div key={subCategoryName} className="mb-4">
          {subCategoryName && <h4 className="font-semibold my-4 px-2 text-primary">{subCategoryName}</h4>}
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {exerciseList.map(ex => {
                  const isSelected = exercises.some(loggedEx => loggedEx.name === ex.name);
                  return (
                    <div
                      key={ex.name}
                      onClick={() => toggleExercise(ex.name)}
                      className={cn(
                        "rounded-lg cursor-pointer group border-2 p-2 text-center space-y-2 transition-all",
                        isSelected
                          ? "border-primary bg-primary/5"
                          : "border-transparent bg-muted/50 hover:bg-muted/100"
                      )}
                    >
                      <div className="aspect-square w-full relative overflow-hidden rounded-md bg-muted-foreground/10">
                        <Image
                          src={ex.image}
                          alt={ex.name}
                          width={200}
                          height={200}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          data-ai-hint={ex.hint}
                        />
                      </div>
                      <h3 className="font-medium text-sm text-foreground h-10 flex items-center justify-center">{ex.name}</h3>
                    </div>
                  )
              })}
          </div>
      </div>
    );
    
    return (
      <Card className="w-full max-w-4xl mx-auto shadow-xl border-none bg-card/70 flex flex-col flex-1">
        <CardHeader>
          <div className="flex items-center gap-4">
            <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(2)}>
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <div>
              <CardTitle className="flex items-center gap-2"><Dumbbell /> Select Your Exercises</CardTitle>
              <CardDescription>
                Choose the exercises for your workout on {date ? format(date, "PPP") : 'the selected date'} at {time}.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="flex-1 flex flex-col gap-4">
             <div className="flex justify-between items-center">
                <p className="text-sm text-muted-foreground">Click an exercise to add it to your log. You have selected {exercises.length} exercises.</p>
             </div>
             <ScrollArea className="flex-1 -mx-2">
                <div className="px-2">
                  {selectedCategories.map(category => {
                    const categoryData = exerciseData[category as keyof typeof exerciseData];
                    if (!categoryData) return null;

                    if (isExerciseList(categoryData)) {
                      return renderExercises(categoryData);
                    }
                    
                    if (isSubCategory(categoryData)) {
                      return categoryData.subCategories.map(sub => {
                          if (isExerciseList(sub.exercises)) {
                            return renderExercises(sub.exercises, sub.name)
                          }
                          // This handles the new nested structure for Upper Chest
                          if (isSubCategory(sub.exercises)) {
                              return (
                                <div key={sub.name}>
                                    <h3 className="font-bold text-xl mt-6 mb-2 px-2 text-foreground">{sub.name}</h3>
                                    {sub.exercises.subCategories.map(nestedSub => renderExercises(nestedSub.exercises, nestedSub.name))}
                                </div>
                              )
                          }
                          return null;
                      });
                    }
                    
                    return null;
                  })}
                </div>
              </ScrollArea>
        </CardContent>
        <CardFooter>
             <Button onClick={() => setStep(4)} className="w-full" size="lg" disabled={exercises.length === 0}>
                Next - Log Details <ChevronRight className="ml-2 h-4 w-4" />
            </Button>
        </CardFooter>
      </Card>
    );
  }

  if (step === 4) {
    return (
      <Card className="w-full max-w-2xl mx-auto shadow-xl border-none bg-card/70 flex flex-col flex-1">
        <CardHeader>
          <div className="flex items-center gap-4">
            <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setStep(3)}>
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <div>
              <CardTitle className="flex items-center gap-2"><Dumbbell /> Log Your Details</CardTitle>
              <CardDescription>
                Fill in your sets, reps, and weight for each exercise.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="flex-1">
          <ScrollArea className="h-[500px] p-4 -mx-4">
              {exercises.length === 0 ? (
                  <div className="text-center text-muted-foreground h-full flex flex-col justify-center items-center">
                      <p>No exercises added yet.</p>
                      <Button variant="link" onClick={() => setStep(3)}>Go back to select exercises</Button>
                  </div>
              ) : (
                <div className="space-y-4">
                  {exercises.map((exercise) => (
                      <Card key={exercise.id} className="p-4 bg-background/50 relative">
                          <Button variant="ghost" size="icon" className="absolute top-2 right-2 h-7 w-7 text-muted-foreground hover:bg-destructive/10 hover:text-destructive" onClick={() => removeExercise(exercise.id)}>
                              <Trash2 className="h-4 w-4" />
                          </Button>
                          <div className="space-y-2">
                              <Label className="font-semibold text-base">{exercise.name}</Label>
                              <div className="space-y-2">
                                  {exercise.sets.map((set, setIndex) => (
                                      <div key={set.id} className="flex gap-2 items-center">
                                          <span className="text-sm font-medium text-muted-foreground w-8 text-center">#{setIndex + 1}</span>
                                          <Input type="number" placeholder="Reps" value={set.reps} onChange={(e) => updateSet(exercise.id, set.id, 'reps', e.target.value)} />
                                          <Input placeholder="Weight (kg/lbs)" value={set.weight} onChange={(e) => updateSet(exercise.id, set.id, 'weight', e.target.value)} />
                                          <Button variant="ghost" size="icon" className="h-8 w-8 shrink-0 text-muted-foreground hover:bg-destructive/10 hover:text-destructive" onClick={() => removeSet(exercise.id, set.id)} disabled={exercise.sets.length <= 1}>
                                              <Trash2 className="h-4 w-4" />
                                          </Button>
                                      </div>
                                  ))}
                                  <Button variant="outline" size="sm" onClick={() => addSet(exercise.id)} className="w-full">
                                      <PlusCircle className="mr-2 h-4 w-4" /> Add Set
                                  </Button>
                              </div>
                          </div>
                      </Card>
                  ))}
                </div>
              )}
          </ScrollArea>
        </CardContent>
        <CardFooter>
             <Button onClick={handleSubmit} className="w-full bg-accent hover:bg-accent/90 text-accent-foreground" disabled={exercises.length === 0}>
                <CheckCircle className="mr-2 h-4 w-4" /> Finish &amp; Log Workout
            </Button>
        </CardFooter>
      </Card>
    );
  }

  // Fallback return if step is not valid
  return null;
}
