/**
 * 英文から単語を抽出し、選択・登録する機能を管理
 */
import $ from "jquery";

$(document).on("turbo:load", function () {
  const MAX_WORDS = 20; // 選択可能な単語の最大数

  // 英文入力から単語選択画面への遷移
  $("#start-extraction").off().on("click", function () {
    const originalText = $("#original-text").val().trim();
    if (!originalText) return;

    // 英文を単語に分割し、記号を除去
    const words = originalText.split(/\s+/).map(word => word.replace(/[.,:;!?()"'`]/g, ""));
    const container = $("#extraction-result");
    container.empty();

    // 各単語をクリック可能な要素として追加
    words.forEach((word) => {
      if (word.trim() === "") return; // 空文字列を除外
      const span = $("<span>")
        .text(word)
        .addClass("inline-block px-2 py-1 m-1 border rounded cursor-pointer bg-gray-100 hover:bg-yellow-100")
        .on("click", function () {
          // 選択状態の切り替え
          $(this).toggleClass("bg-yellow-300");

          // 選択単語数のバリデーション
          const selectedCount = $("#extraction-result span.bg-yellow-300").length;
          if (selectedCount > MAX_WORDS) {
            alert(`選択できる単語は最大${MAX_WORDS}個までです。`);
            $(this).removeClass("bg-yellow-300"); // 選択を解除
          }
        });
      container.append(span);
    });

    // 画面を単語選択モードに切り替え
    $("#extraction-input-area").addClass("hidden");
    $("#extraction-selection-area").removeClass("hidden");
  });

  // 単語選択画面から英文入力画面に戻る処理
  $("#extraction-cancel").off().on("click", function () {
    $("#extraction-selection-area").addClass("hidden");
    $("#extraction-input-area").removeClass("hidden");
  });

  // 選択された単語を送信する処理
  $("#extraction-next").off().on("click", function () {
    const selectedWords = [];
    $("#extraction-result span.bg-yellow-300").each(function () {
      selectedWords.push($(this).text());
    });

    // 単語数のバリデーション
    if (selectedWords.length > MAX_WORDS) {
      alert(`選択できる単語は最大${MAX_WORDS}個までです。`);
      return; // 処理を中断
    }

    if (selectedWords.length === 0) {
      alert("抽出する単語を選択してください。");
      return; // 処理を中断
    }

    // フォームを動的に生成して送信
    const form = $("#selected-words-form");
    form.empty();
    form.attr("method", "post");
    form.attr("action", "/extractions/fetch_meanings");

    // CSRFトークンを設定
    const token = $('meta[name="csrf-token"]').attr('content');
    if (token) {
      form.append(`<input type="hidden" name="authenticity_token" value="${token}">`);
    }

    // 選択された単語をhidden inputとして追加
    selectedWords.forEach((word, index) => {
      const input = `<input type='hidden' id='word-${index}' name='words[]' value='${word}'>`;
      form.append(input);
    });

    form.submit(); // フォームを送信
  });

  // 選択された単語と意味を登録する処理
  $("#extraction-register").off().on("click", function () {
    const selectedWords = [];

    // 選択された単語とその意味を収集
    $("#extraction-result span.bg-yellow-300").each(function () {
      const word = $(this).text();
      const meaning = $(this).data("meaning") || ""; // 意味を取得
      const truncatedMeaning = meaning.substring(0, 200); // 200文字以内に切り詰める
      selectedWords.push({ word, meaning: truncatedMeaning });
    });

    if (selectedWords.length === 0) {
      alert("単語を選択してください。");
      return; // 処理を中断
    }

    // サーバーに送信
    $.ajax({
      url: "/extractions/register",
      type: "POST",
      data: {
        entries: selectedWords,
        authenticity_token: $('meta[name="csrf-token"]').attr("content"),
      },
      success: function () {
        alert("単語が登録されました！");
      },
      error: function () {
        alert("単語の登録に失敗しました。");
      },
    });
  });

  // フォルダ選択時に単語帳リストを更新
  $("#folder-select").off().on("change", function () {
    const folderId = $(this).val();
    const $wordbookSelect = $("#wordbook-select");

    if (!folderId) {
      $wordbookSelect.empty().append("<option value=''>単語帳を選択</option>");
      return;
    }

    // APIから単語帳リストを取得
    $.ajax({
      url: `/folders/${folderId}/wordbooks_list.json`,
      type: "GET",
      dataType: "json",
      success: function (data) {
        $wordbookSelect.empty().append("<option value=''>単語帳を選択</option>");
        data.forEach((wordbook) => {
          $wordbookSelect.append(
            `<option value="${wordbook.id}">${wordbook.title}</option>`
          );
        });
      },
      error: function () {
        alert("単語帳の取得に失敗しました。");
      },
    });
  });
});