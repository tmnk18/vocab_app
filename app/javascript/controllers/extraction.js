import $ from "jquery";

$(document).on("turbo:load", function () {
  let originalText = "";

  // OKボタン → 単語選択モードへ
  $("#start-extraction").off().on("click", function () {
    originalText = $("#original-text").val().trim();
    if (!originalText) return;

    const words = originalText.split(/\s+/);
    const container = $("#extraction-result");
    container.empty();

    words.forEach((word) => {
      const span = $("<span>")
        .text(word)
        .addClass("inline-block px-2 py-1 m-1 border rounded cursor-pointer bg-gray-100 hover:bg-yellow-100")
        .on("click", function () {
          $(this).toggleClass("bg-yellow-300");
        });
      container.append(span);
    });

    $("#extraction-input-area").addClass("hidden");
    $("#extraction-selection-area").removeClass("hidden");
  });

  // キャンセル → 入力画面に戻す
  $("#extraction-cancel").off().on("click", function () {
    $("#extraction-selection-area").addClass("hidden");
    $("#extraction-input-area").removeClass("hidden");
    $("#original-text").val(originalText);
  });

  // 抽出ボタン → hidden input に選択単語を追加し送信
  $("#extraction-next").off().on("click", function () {
    const selectedWords = [];
    $("#extraction-result span.bg-yellow-300").each(function () {
      selectedWords.push($(this).text());
    });

    if (selectedWords.length === 0) {
      alert("抽出する単語を選択してください。");
      return;
    }

    const form = $("#selected-words-form");
    form.empty();

    form.attr("method", "post");
    form.attr("action", "/extractions/fetch_meanings");

    const token = $('meta[name="csrf-token"]').attr('content');
    if (token) {
      form.append(`<input type="hidden" name="authenticity_token" value="${token}">`);
    }

    selectedWords.forEach((word, index) => {
      const input = `<input type='hidden' id='word-${index}' name='words[]' value='${word}'>`;
      form.append(input);
    });

    form.submit();
  });

  $("#folder-select").off().on("change", function () {
    const folderId = $(this).val();
    const $wordbookSelect = $("#wordbook-select");

    if (!folderId) {
      $wordbookSelect.empty().append("<option value=''>単語帳を選択</option>");
      return;
    }

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