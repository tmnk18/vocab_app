/**
 * 英文からの単語抽出機能を管理するJavaScriptモジュール
 * 単語の抽出、選択、および単語帳への登録までの一連のプロセスを制御
 */
import $ from "jquery";

$(document).on("turbo:load", function () {
  const MAX_WORDS = 10; // 選択できる単語の最大数

  // 元の英文を保持する変数
  let originalText = "";

  /**
   * 英文入力から単語選択モードへの遷移を処理
   * - 入力された英文を単語に分割
   * - 各単語をクリック可能な要素として表示
   * - 画面の表示を切り替え
   */
  $("#start-extraction").off().on("click", function () {
    originalText = $("#original-text").val().trim();
    if (!originalText) return;

    // 単語を分割し、記号を除去（カンマ、ピリオド、引用符など）
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
          $(this).toggleClass("bg-yellow-300"); // クリックで選択/選択解除

          // 単語数のバリデーション
          const selectedCount = $("#extraction-result span.bg-yellow-300").length;
          if (selectedCount > MAX_WORDS) {
            alert(`選択できる単語は最大${MAX_WORDS}個までです。`);
            $(this).removeClass("bg-yellow-300"); // 選択を解除
          }
        });
      container.append(span);
    });

    // 画面の表示を切り替え
    $("#extraction-input-area").addClass("hidden");
    $("#extraction-selection-area").removeClass("hidden");
  });

  /**
   * 入力画面への戻る処理
   * - 単語選択画面を非表示
   * - 入力画面を表示
   * - 元の英文を復元
   */
  $("#extraction-cancel").off().on("click", function () {
    $("#extraction-selection-area").addClass("hidden");
    $("#extraction-input-area").removeClass("hidden");
    $("#original-text").val(originalText);
  });

  /**
   * 選択された単語の送信処理
   * - 選択された単語を収集
   * - CSRFトークンを設定
   * - フォームを動的に生成して送信
   */
  $("#extraction-next").off().on("click", function () {
    // 選択された単語（黄色でハイライトされた要素）を収集
    const selectedWords = [];
    $("#extraction-result span.bg-yellow-300").each(function () {
      selectedWords.push($(this).text());
    });

    // 単語数のバリデーション
    if (selectedWords.length > MAX_WORDS) {
      alert(`選択できる単語は最大${MAX_WORDS}個までです。`);
      return; // 処理を中断してページ遷移を防ぐ
    }

    // 単語が選択されていない場合はアラート
    if (selectedWords.length === 0) {
      alert("抽出する単語を選択してください。");
      return; // 処理を中断してページ遷移を防ぐ
    }

    // フォームの準備
    const form = $("#selected-words-form");
    form.empty();
    form.attr("method", "post");
    form.attr("action", "/extractions/fetch_meanings");

    // CSRFトークンの設定
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

  /**
   * 選択された単語の意味を取得して送信する処理
   */
  $("#extraction-register").off().on("click", function () {
    const selectedWords = [];
    const meanings = [];

    // 選択された単語とその意味を収集
    $("#extraction-result span.bg-yellow-300").each(function () {
      const word = $(this).text();
      const meaning = $(this).data("meaning") || ""; // 意味を取得（例: data-attributeから）
      
      // 意味を200文字以内に切り詰める
      const truncatedMeaning = meaning.substring(0, 200);

      selectedWords.push({ word, meaning: truncatedMeaning });
    });

    // 単語が選択されていない場合はアラート
    if (selectedWords.length === 0) {
      alert("単語を選択してください。");
      return;
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

  /**
   * フォルダ選択時の単語帳リスト更新
   * - 選択されたフォルダの単語帳一覧を取得
   * - セレクトボックスの選択肢を更新
   */
  $("#folder-select").off().on("change", function () {
    const folderId = $(this).val();
    const $wordbookSelect = $("#wordbook-select");

    // フォルダが選択されていない場合は単語帳リストをクリア
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
        // 単語帳セレクトボックスを更新
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