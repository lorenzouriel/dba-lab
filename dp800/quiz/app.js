(function () {
  "use strict";

  const TIER_LABELS = {
    easy: "Easy",
    medium: "Medium",
    hard: "Hard",
    usecase: "Use case",
  };

  const REPO_BLOB_BASE = "https://github.com/lorenzouriel/dba-lab/blob/main/";
  const LETTERS = ["A", "B", "C", "D"];

  const body = document.body;

  // ---- elements ----
  const modeGrid = document.getElementById("mode-grid");
  const customPanel = document.getElementById("custom-panel");
  const shuffleQuestionsEl = document.getElementById("shuffle-questions");
  const shuffleAnswersEl = document.getElementById("shuffle-answers");
  const startBtn = document.getElementById("start-btn");
  const lastScoreEl = document.getElementById("last-score");

  const exitBtn = document.getElementById("exit-btn");
  const progressFill = document.getElementById("progress-fill");
  const progressLabel = document.getElementById("progress-label");
  const questionTierBadge = document.getElementById("question-tier-badge");
  const questionBreadcrumb = document.getElementById("question-breadcrumb");
  const questionText = document.getElementById("question-text");
  const optionsList = document.getElementById("options-list");
  const explanationPanel = document.getElementById("explanation-panel");
  const explanationVerdict = document.getElementById("explanation-verdict");
  const explanationText = document.getElementById("explanation-text");
  const explanationQuote = document.getElementById("explanation-quote");
  const explanationSourceLink = document.getElementById("explanation-source-link");
  const explanationHeadingLabel = document.getElementById("explanation-heading-label");
  const nextBtn = document.getElementById("next-btn");

  const scoreLine = document.getElementById("score-line");
  const scorePct = document.getElementById("score-pct");
  const tierBreakdown = document.getElementById("tier-breakdown");
  const missedList = document.getElementById("missed-list");
  const retryMissedBtn = document.getElementById("retry-missed-btn");
  const retrySameBtn = document.getElementById("retry-same-btn");
  const backToMenuBtn = document.getElementById("back-to-menu-btn");

  // ---- state ----
  const state = {
    mode: null,
    pool: [],      // array of { q: <original question object>, options: [...], correctIndex }
    index: 0,
    answers: [],   // parallel to pool: { correct: bool, selectedIndex } | null until answered
  };

  function shuffle(arr) {
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function sourceUrl(path) {
    return REPO_BLOB_BASE + path.split("/").map(encodeURIComponent).join("/");
  }

  function buildPool(mode, tiers) {
    let questions;
    if (mode === "all") {
      questions = QUIZ_QUESTIONS.slice();
    } else if (mode === "custom") {
      questions = QUIZ_QUESTIONS.filter((q) => tiers.includes(q.tier));
    } else {
      questions = QUIZ_QUESTIONS.filter((q) => q.tier === mode);
    }
    return questions;
  }

  function instantiatePool(questions, shuffleQ, shuffleA) {
    let list = shuffleQ ? shuffle(questions) : questions.slice();
    return list.map((q) => {
      const optionIndices = q.options.map((_, i) => i);
      const order = shuffleA ? shuffle(optionIndices) : optionIndices;
      return {
        q,
        options: order.map((i) => q.options[i]),
        correctIndex: order.indexOf(q.correctIndex),
      };
    });
  }

  // ---- mode selection (start screen) ----
  let selectedMode = "all";

  modeGrid.addEventListener("click", (e) => {
    const btn = e.target.closest(".mode-card");
    if (!btn) return;
    selectedMode = btn.dataset.mode;
    [...modeGrid.querySelectorAll(".mode-card")].forEach((c) =>
      c.classList.toggle("selected", c === btn)
    );
    customPanel.hidden = selectedMode !== "custom";
  });

  // preselect "all"
  modeGrid.querySelector('[data-mode="all"]').classList.add("selected");

  function currentCustomTiers() {
    return [...customPanel.querySelectorAll('input[type="checkbox"]:checked')].map(
      (c) => c.value
    );
  }

  function lastScoreKey(mode) {
    return "dp800quiz:lastScore:" + mode;
  }

  function showLastScore() {
    try {
      const raw = localStorage.getItem(lastScoreKey(selectedMode));
      if (!raw) {
        lastScoreEl.hidden = true;
        return;
      }
      const data = JSON.parse(raw);
      lastScoreEl.textContent = `Last attempt: ${data.score}/${data.total} (${data.pct}%) · ${data.date}`;
      lastScoreEl.hidden = false;
    } catch (err) {
      lastScoreEl.hidden = true;
    }
  }

  modeGrid.addEventListener("click", showLastScore);
  showLastScore();

  startBtn.addEventListener("click", () => {
    const tiers = selectedMode === "custom" ? currentCustomTiers() : null;
    const questions = buildPool(selectedMode, tiers);
    if (!questions.length) {
      alert("Pick at least one tier to include.");
      return;
    }
    state.mode = selectedMode;
    state.pool = instantiatePool(
      questions,
      shuffleQuestionsEl.checked,
      shuffleAnswersEl.checked
    );
    state.index = 0;
    state.answers = new Array(state.pool.length).fill(null);
    body.dataset.screen = "quiz";
    renderQuestion();
  });

  // ---- quiz screen ----

  function renderQuestion() {
    const item = state.pool[state.index];
    const q = item.q;

    progressFill.style.width = ((state.index) / state.pool.length) * 100 + "%";
    progressLabel.textContent = `Question ${state.index + 1} of ${state.pool.length}`;

    questionTierBadge.textContent = TIER_LABELS[q.tier] || q.tier;
    questionTierBadge.className = "tier-badge tier-" + q.tier;
    questionBreadcrumb.textContent = `${q.domain} › ${q.module}`;
    questionText.textContent = q.question;

    optionsList.innerHTML = "";
    item.options.forEach((optionText, i) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "option-btn";
      btn.dataset.index = String(i);
      btn.innerHTML =
        `<span class="option-letter">${LETTERS[i] || i + 1}</span><span class="option-body"></span>`;
      btn.querySelector(".option-body").textContent = optionText;
      btn.addEventListener("click", () => selectAnswer(i));
      optionsList.appendChild(btn);
    });

    explanationPanel.hidden = true;
    nextBtn.hidden = true;
  }

  function selectAnswer(selectedIndex) {
    if (state.answers[state.index]) return; // already answered

    const item = state.pool[state.index];
    const correct = selectedIndex === item.correctIndex;
    state.answers[state.index] = { correct, selectedIndex };

    const buttons = [...optionsList.querySelectorAll(".option-btn")];
    buttons.forEach((btn) => {
      btn.disabled = true;
      const i = Number(btn.dataset.index);
      if (i === item.correctIndex) btn.classList.add("correct");
      else if (i === selectedIndex) btn.classList.add("incorrect");
    });

    explanationVerdict.textContent = correct ? "Correct" : "Not quite";
    explanationVerdict.className = "explanation-verdict " + (correct ? "correct" : "incorrect");
    explanationText.textContent = item.q.explanation;

    if (item.q.source && item.q.source.quote) {
      explanationQuote.textContent = "“" + item.q.source.quote + "”";
      explanationQuote.hidden = false;
    } else {
      explanationQuote.hidden = true;
    }

    if (item.q.source) {
      explanationSourceLink.href = sourceUrl(item.q.source.path);
      explanationSourceLink.textContent = item.q.source.path;
      explanationHeadingLabel.textContent = item.q.source.heading
        ? "Section: " + item.q.source.heading
        : "";
    }

    explanationPanel.hidden = false;
    nextBtn.hidden = false;
  }

  nextBtn.addEventListener("click", () => {
    if (state.index < state.pool.length - 1) {
      state.index += 1;
      renderQuestion();
    } else {
      finishQuiz();
    }
  });

  exitBtn.addEventListener("click", () => {
    body.dataset.screen = "start";
    showLastScore();
  });

  // ---- results screen ----

  function finishQuiz() {
    progressFill.style.width = "100%";

    const total = state.pool.length;
    const correctCount = state.answers.filter((a) => a && a.correct).length;
    const pct = Math.round((correctCount / total) * 100);

    scoreLine.textContent = `${correctCount} / ${total}`;
    scorePct.textContent = `${pct}%`;

    try {
      localStorage.setItem(
        lastScoreKey(state.mode),
        JSON.stringify({
          score: correctCount,
          total,
          pct,
          date: new Date().toLocaleDateString(),
        })
      );
    } catch (err) {
      /* localStorage unavailable — ignore, it's a nicety only */
    }

    renderTierBreakdown();
    renderMissedList();

    body.dataset.screen = "results";
  }

  function renderTierBreakdown() {
    const tiers = ["easy", "medium", "hard", "usecase"];
    const rows = tiers
      .map((tier) => {
        const items = state.pool
          .map((item, i) => ({ item, answer: state.answers[i] }))
          .filter(({ item }) => item.q.tier === tier);
        if (!items.length) return null;
        const correct = items.filter(({ answer }) => answer && answer.correct).length;
        const pct = Math.round((correct / items.length) * 100);
        return `
          <div class="tier-row">
            <span class="tier-row-label tier-${tier}-text" style="color:var(--tier-${tier})">${TIER_LABELS[tier]}</span>
            <div class="tier-row-track">
              <div class="tier-row-fill" style="width:${pct}%;background:var(--tier-${tier})"></div>
            </div>
            <span class="tier-row-score">${correct}/${items.length}</span>
          </div>`;
      })
      .filter(Boolean)
      .join("");
    tierBreakdown.innerHTML = rows;
  }

  function renderMissedList() {
    const missed = state.pool
      .map((item, i) => ({ item, answer: state.answers[i] }))
      .filter(({ answer }) => answer && !answer.correct);

    if (!missed.length) {
      missedList.innerHTML = '<p class="no-missed">Nothing missed — clean sweep.</p>';
      return;
    }

    missedList.innerHTML = missed
      .map(({ item, answer }) => {
        const yourAnswer = item.options[answer.selectedIndex];
        const correctAnswer = item.options[item.correctIndex];
        const src = item.q.source;
        const sourceHtml = src
          ? `<p class="missed-source">Source: <a href="${sourceUrl(src.path)}" target="_blank" rel="noopener">${src.path}</a>${
              src.heading ? " — " + escapeHtml(src.heading) : ""
            }</p>`
          : "";
        return `
          <div class="missed-item">
            <p class="missed-question">${escapeHtml(item.q.question)}</p>
            <p class="missed-your-answer">Your answer: ${escapeHtml(yourAnswer)}</p>
            <p class="missed-correct-answer">Correct answer: ${escapeHtml(correctAnswer)}</p>
            <p class="missed-explanation">${escapeHtml(item.q.explanation)}</p>
            ${sourceHtml}
          </div>`;
      })
      .join("");
  }

  function escapeHtml(str) {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML;
  }

  retrySameBtn.addEventListener("click", () => {
    const questions = state.pool.map((item) => item.q);
    state.pool = instantiatePool(
      questions,
      shuffleQuestionsEl.checked,
      shuffleAnswersEl.checked
    );
    state.index = 0;
    state.answers = new Array(state.pool.length).fill(null);
    body.dataset.screen = "quiz";
    renderQuestion();
  });

  retryMissedBtn.addEventListener("click", () => {
    const missedQuestions = state.pool
      .filter((item, i) => state.answers[i] && !state.answers[i].correct)
      .map((item) => item.q);
    if (!missedQuestions.length) return;
    state.pool = instantiatePool(
      missedQuestions,
      shuffleQuestionsEl.checked,
      shuffleAnswersEl.checked
    );
    state.index = 0;
    state.answers = new Array(state.pool.length).fill(null);
    body.dataset.screen = "quiz";
    renderQuestion();
  });

  backToMenuBtn.addEventListener("click", () => {
    body.dataset.screen = "start";
    showLastScore();
  });

  // ---- keyboard shortcuts during quiz ----
  document.addEventListener("keydown", (e) => {
    if (body.dataset.screen !== "quiz") return;
    if (!nextBtn.hidden && (e.key === "Enter" || e.key === " ")) {
      e.preventDefault();
      nextBtn.click();
      return;
    }
    const digit = Number(e.key);
    if (digit >= 1 && digit <= 4) {
      const btn = optionsList.querySelector(`.option-btn[data-index="${digit - 1}"]`);
      if (btn && !btn.disabled) btn.click();
    }
  });
})();
