---
name: dp300-quiz
description: Generate and run DP-300 exam practice Q&A sourced from the condensed notes under dp300/content/. Use when the user wants to study, drill, quiz, test themselves, or get practice/review questions for DP-300, or asks to generate flashcards/a study sheet from the dp300 folder. Trigger phrases include "quiz me on DP-300", "dp300 practice questions", "test me on [module]", "generate flashcards from dp300".
---

# DP-300 practice quiz

Generates original exam-style question-and-answer material from the course notes in
`dp300/content/` (relative to the repo root) and drills the user on it.

## Source content

`dp300/content/` is organized as one condensed `README.md` per module (unlike the
numbered-lesson layout of the other DP courses in this repo), still being filled in
over time:

```
dp300/content/
  <Domain>/
    <Module>/
      README.md      (dense notes covering the whole module topic)
```

Do not assume a fixed list of domains/modules — glob `dp300/content/**/README.md` (or
`Glob` with pattern `dp300/content/**/*.md`) each time to see what currently exists,
since files get added over time.

Each `README.md` is compact but typically covers multiple sub-topics under `##`
headings — treat each heading as a distinct concept when spreading questions across
the file, not just the module as a whole.

## Step 1 — scope the session

Look at what the user passed as args:

- A domain name, module name, or filename fragment (fuzzy match against the glob
  results, case-insensitive, partial match on folder names) → scope to the matching
  module(s).
- Empty / "all" / "random" → scope to the whole tree, and when picking questions,
  sample across domains rather than exhausting one module first.
- If args are ambiguous (matches multiple unrelated modules), ask the user to pick
  one with AskUserQuestion rather than guessing.

## Step 2 — read the source notes

Read every `README.md` in scope before writing questions. For a whole-domain or
whole-tree scope where this would mean reading a large number of files, it's fine to
delegate the reading + question-drafting to an Explore or general-purpose subagent per
module to keep your own context small — but you (not the subagent) do the final
interactive quizzing.

## Step 3 — generate questions

Write **original** multiple-choice questions (not lifted from the source):

- 3-4 plausible options, exactly one correct.
- Mix recall ("what is X") with applied/scenario questions ("a database is
  experiencing Y, what should the DBA do") and comparison questions ("when should you
  use A over B", e.g. Always On availability groups vs. failover clustering, or
  transparent data encryption vs. Always Encrypted).
- Cover the range of concepts in the scoped material — since each README packs several
  sub-topics into one file, spread questions across the `##` sections rather than
  clustering on the first one.
- Note internally (don't show the user yet) the correct answer and a one-line
  rationale citing the concept from the source file.
- Default to 8-10 questions per module (each README is dense enough to support this),
  more (e.g. 15-20) only if the user asks for a longer session or scopes to "all".

## Step 4 — run the quiz interactively

This is a study drill, not a document-generation task — default to running it
live in the conversation:

1. Ask one question at a time, numbered, with lettered options.
2. Wait for the user's answer before revealing anything.
3. After each answer, say correct/incorrect immediately, give the one-line rationale,
   and name the source module (folder) so the user can go re-read it if needed.
4. At the end, report a score and list which topics/modules the misses came from, so
   the user knows what to review next.

Only skip the interactive flow and instead write a Markdown Q&A/flashcard file when
the user explicitly asks to "generate", "save", "export", or "write" a study sheet —
in that case put it under `dp300/practice/` (create the folder if needed), named after
the scoped module, with answers hidden behind a `<details>` disclosure or listed in a
separate answer-key section at the end.

## Notes

- This is exam prep, not a graded assessment — keep tone encouraging, and if the user
  gets something wrong twice, offer a short plain-language explanation of the concept
  itself, not just "re-read the file."
- If the user asks for the DP-300 exam's official structure/weighting, don't invent
  numbers — say the course tree is what's available locally and answer from that.
