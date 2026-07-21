---
name: dp800-quiz
description: Generate and run DP-800 exam practice Q&A sourced from the lesson content under dp800/. Use when the user wants to study, drill, quiz, test themselves, or get practice/review questions for DP-800, or asks to generate flashcards/a study sheet from the dp800 folder. Trigger phrases include "quiz me on DP-800", "dp800 practice questions", "test me on [module]", "generate flashcards from dp800".
---

# DP-800 practice quiz

Generates original exam-style question-and-answer material from the course notes in
`dp800/` (relative to the repo root) and drills the user on it.

## Source content

`dp800/` is a Microsoft-Learn-style course tree, still being filled in over time:

```
dp800/
  <Domain>/
    <Module>/
      01-introduction.md
      02-...md ... NN-...md
      NN-exercise-....md          (hands-on lab, optional source material)
      NN-knowledge-check.md       (existing MCQs — style reference only)
      NN-module-assessment.md     (existing MCQs — style reference only)
      NN-summary.md
```

Do not assume a fixed list of domains/modules — glob `dp800/**/*.md` (or `Glob` with
pattern `dp800/**/*.md`) each time to see what currently exists, since files get added
over time and some modules are still stubs (an intro-only file).

## Step 1 — scope the session

Look at what the user passed as args:

- A domain name, module name, or filename fragment (fuzzy match against the glob
  results, case-insensitive, partial match on folder/file names) → scope to the
  matching file(s).
- Empty / "all" / "random" → scope to the whole tree, and when picking questions,
  sample across domains rather than exhausting one folder first.
- If args are ambiguous (matches multiple unrelated modules), ask the user to pick
  one with AskUserQuestion rather than guessing.

Skip `NN-exercise-*.md` (hands-on lab steps, not conceptual content) as a source when
generating new questions, but do read `NN-knowledge-check.md` and
`NN-module-assessment.md` when present — use them only as a **style reference**
(question phrasing, scenario framing, number of options), never copy them verbatim.

## Step 2 — read the source lessons

Read every numbered lesson file in scope (excluding exercises) before writing
questions. For a whole-domain or whole-tree scope where this would mean reading a
large number of files, it's fine to delegate the reading + question-drafting to an
Explore or general-purpose subagent per module to keep your own context small — but
you (not the subagent) do the final interactive quizzing.

## Step 3 — generate questions

Write **original** multiple-choice questions (not lifted from the source), matching
the style already used in this course's own assessments:

- 3-4 plausible options, exactly one correct.
- Mix recall ("what is X") with applied/scenario questions ("a company needs Y, which
  feature should they use") and comparison questions ("when should you use A over B").
- Cover the range of concepts in the scoped material — don't cluster all questions on
  one paragraph.
- Note internally (don't show the user yet) the correct answer and a one-line
  rationale citing the concept from the source file.
- Default to 8-10 questions for a single module, fewer for a single lesson file, more
  (e.g. 15-20) only if the user asks for a longer session or scopes to "all".

## Step 4 — run the quiz interactively

This is a study drill, not a document-generation task — default to running it
live in the conversation:

1. Ask one question at a time, numbered, with lettered options.
2. Wait for the user's answer before revealing anything.
3. After each answer, say correct/incorrect immediately, give the one-line rationale,
   and name the source lesson file so the user can go re-read it if needed.
4. At the end, report a score and list which topics/files the misses came from, so the
   user knows what to review next.

Only skip the interactive flow and instead write a Markdown Q&A/flashcard file when
the user explicitly asks to "generate", "save", "export", or "write" a study sheet —
in that case put it under `dp800/practice/` (create the folder if needed), named after
the scoped module, with answers hidden behind a `<details>` disclosure or listed in a
separate answer-key section at the end.

## Notes

- This is exam prep, not a graded assessment — keep tone encouraging, and if the user
  gets something wrong twice, offer a short plain-language explanation of the concept
  itself, not just "re-read the file."
- If the user asks for the DP-800 exam's official structure/weighting, don't invent
  numbers — say the course tree is what's available locally and answer from that.
