
Require Import Arith Bool.

Section Basics.

  (* At its core, Coq is a *typed* programing language *)
  (* There are a few (not many!) built-in types *)
  Check 3.
  Check 3 + 4.
  Check true.
  Check (true && false).

  (* And so it can evaluate programs *)
  Eval compute in 3 + 4.
  Eval compute in (true && false).

  (* Every top-level command starts with a capital letter and ends with a period. *)
  (* Grammar was very important to the original implementers... *)
  
  (* No side effects though, so no printing, scanning or reading from a file! *)
  Fail Check print.

  (* There are good reasons for this, which we will go into later *)

  (* We can define types. This is a simple sum type *)
  Inductive week_day :=
  | Monday : week_day
  | Tuesday : week_day
  | Wednesday : week_day
  | Thursday : week_day
  | Friday : week_day
  | Saturday : week_day
  | Sunday : week_day.

  (* And we can define functions *)
  Definition add_one (x : nat) := x + 1.
  Definition return_monday (w : week_day) := Monday.

  Check add_one.
  Check return_monday.

  (* We can work by cases over sum types. *)
  Definition is_monday (w : week_day) :=
    match w with
    | Monday => true
    | _ => false
    end.

  Check is_monday.

  Eval compute in (is_monday Tuesday).

  (* There is a powerful search feature, which takes types and returns
     potentially useful functions with similar types *)
  SearchAbout (bool -> bool).

  (* We can define types which may be recursive, e.g. the type of lists *)
  Inductive week_day_list :=
  | Nil : week_day_list
  | Cons : week_day -> week_day_list -> week_day_list.

  Check (Cons Monday (Cons Tuesday Nil)).

  (* Ok, we have lisp-style lists. Can we define car? *)
  Definition car (l : week_day_list) (default : week_day) : week_day :=
    match l with
    | Nil => default
    | Cons w _ => w
    end.
  (* We need a default value! A little unfortunate... but the price of being pure! *)

  (* How about cdr? *)
  Definition cdr (l : week_day_list) : week_day_list :=
    match l with
    | Nil => Nil
    | Cons _ l' => l'
    end.

  (* List notation a la lisp is tedious. Gladly, Coq's notation system is incredibly powerful! *)

  Notation "[ ]" := Nil.

  Notation "[ w ]" := (Cons w Nil).

  Notation "[ w1 ; w2 ; .. ; wn ]" := (Cons w1 (Cons w2 .. (Cons wn Nil) .. )).

  Definition work_week := [Monday; Tuesday; Wednesday; Thursday; Friday].
  
  (* All right, let's define some funner things. *)

  Definition eq_wd (w1 w2 : week_day) : bool :=
    match (w1, w2) with
    | (Monday,Monday) => true
    | (Tuesday,Tuesday) => true
    | (Wednesday,Wednesday) => true
    | (Thursday,Thursday) => true
    | (Friday,Friday) => true
    | (Saturday,Saturday) => true
    | (Sunday,Sunday) => true
    | _ => false
    end.

  (* How about a length function? This requires a special syntax: *)
  Fixpoint length (l : week_day_list) : nat :=
    match l with
    | [] => 0
    | Cons w ws => (length ws) + 1
    end.

  Eval compute in (length work_week).

  (* Now let's define a membership function *)
  Fixpoint is_a_member (w : week_day) (l : week_day_list) : bool :=
    match l with
    | [] => false
    | Cons w' ws => eq_wd w w' || is_a_member w ws
    end.

  (* Let's test it: *)
  Eval compute in (is_a_member Monday work_week).
  Eval compute in (is_a_member Sunday work_week).

  (* Ok, we're ready for some specifications! *)
  (* The simplest kind of specification is equality: *)
  Check (Monday = Monday).

  (* The Prop type is the type of *specifications*. It is *not* bool! *)
  Check (forall w, w = Monday).
  Check (exists w, w = Monday).

  (* The basic  propositional connectives: *)
  (* True. Always satisfied. *)
  (* False. Never satisfied. *)
  (* P\/Q. Satisfied if one of P or Q (or both) is satisfied. *)
  (* P/\Q. Satisfied if both P and Q are satisfied. *)
  (* P -> Q. Satisfied if, when *assuming* P is satisfied, then so is Q. *)
  (* ~P. Satisfied if P is *never* satisfied *)
  (* forall x : A, P x. Satisfied if for an *aribitrary* x (of type A), P x is satisfied. *)
  (* exists x : A, P x. Satisfied if there is some *specific* a such that P a is satisfied. *)

  
  (* Obviously, we can state specifications about infinite types as well: *)

  Check (forall l : week_day_list, l = [] \/ exists w l', l = Cons w l').

  (* Some of these specifications are satisfied, some are not. *)

  (* We give some basic tools to prove some of these specs: *)


  
  Lemma test1 : forall x y : week_day, x = y -> x = y.
  Proof.
  Abort.
    

  (* ---------------------------------------------------------
     There are some simple cheats on how to prove various kinds of specifications:
     roughly, one can try certain tactics based on the *shape* of the goal and the
     hypotheses. The breakdown is like this:

     |               |   in goal   |   in hypotheses   |
     |---------------+---------+---------------------- |
     | A -> B        |  intros     |      apply        |
     | A /\ B        |  split      |     destruct      |
     | A \/ B        |  left/right |     destruct      |
     | ~A            |  intro      |      apply        |
     |  True         |  trivial    |       N/A         |
     |  False        |    N/A      |   contradiction   |
     | forall x, P x |  intros     |      apply        |
     | exists x, P x |  exists t   |     destruct      |
     | t = u         | reflexivity | rewrite/inversion |

     but of course, these will not alway suffice in all situations.
   *)


  (* Here's how one proves trivial equalities: *)
  Lemma test2 : Monday = Monday.
  Proof.
  Abort.

  (* It's nice to know that this doesn't always work: *)
  Lemma test2_fail : Monday = Friday.
  Proof.
    Fail reflexivity.
  Abort.

  (* We can also perform computation steps in proofs, in order to
     prove things about functions: *)
  Lemma test3 : return_monday Friday = Monday.
  Proof.
  Abort.

  Lemma test3' : length work_week = 5.
  Proof.
  Abort.

  (* But really we're interested in behavior over *all inputs*. *)
  Lemma test4 : forall x : week_day, return_monday x = Monday.
  Proof.
  Abort.
  
  (* How about this? *)
  Lemma test5 : forall x : week_day, eq_wd x x = true.
  Proof.
  Abort.
  
  (* Let's play with some logical connectives *)
  Lemma test6 : forall x y z : week_day, x = y -> y = z -> x = y /\ y = z.
  Proof.
  Abort.
    
  Lemma test7 : forall x y z : week_day, x = y -> x = y \/ y = z.
  Proof.
  Abort.
  
  Lemma test8 : forall x y z : week_day, x = y /\ y = z -> y = z.
  Proof.
  Abort.
    
  Lemma test9 : forall x y : week_day, x = y \/ x = y -> x = y.
  Proof.
  Abort.
    
  Lemma test10 : forall x y, x = Monday -> y = x -> y = Monday.
  Proof.
  Abort.
    
  (* Proofs involving equalities *)
  Lemma test11 : Monday = Tuesday -> False.
  Proof.
  Abort.
    
  (* All right we're ready for some serious stuff *) 
  Lemma first_real_lemma : forall x y, x = y -> eq_wd x y = true.
  Proof.
  Abort.
  
  (* The other direction is harder! *)
  Lemma second_real_lemma : forall x y, eq_wd x y = true -> x = y.
  Proof.
  Abort.

  (* Now we have a program which we have proven correct! We can use this to prove some theorems! *)
  Lemma test12 : Monday = Monday.
  Proof.
  Abort.
  
  (* Let's show correctness of our membership function! But first we need to *specify* membership. *)
  (* To do this, we specify an *inductive predicate*, which describes all the ways an element can be in a list. *)
  (* We can again use the keyword inductive. *)
  Inductive Mem : forall (w : week_day) (l : week_day_list), Prop :=
  | Mem_head : forall w l, Mem w (Cons w l)
  | Mem_tail : forall w w' l, Mem w l -> Mem w (Cons w' l).


  (* We can apply constructors of mem like lemmas *)
  Lemma test13 : Mem Monday [Tuesday; Monday; Thursday].
  Proof.
  Abort.

  (* Here's some fun existential statements: *)
  Lemma test14 : exists w, Mem w work_week.
  Proof.
  Abort.

  (* This is harder! We'll be able to prove this easily once we have the
     theorems.
   *)
  Lemma test15 : exists w, ~ (Mem w work_week).
  Proof.
  Abort.
  
  (* The theorems we want are these: *)
  Theorem is_a_member_correct : forall w l, is_a_member w l = true -> Mem w l.
  Proof.
  Abort.

  Theorem is_a_member_complete : forall w l, Mem w l -> is_a_member w l = true.
  Proof.
  Abort.


  (* Need to learn: simpl, induction *)