import "./controllers/extraction"
import "@hotwired/turbo-rails"
import "controllers"
import $ from "jquery"
import Rails from "@rails/ujs"
Rails.start()

/**
 * アプリケーションのメインJavaScriptファイル
 * 単語帳アプリケーションのクライアントサイド機能を管理
 */

// CSRFトークンの設定
$(document).on('turbo:load', function () {
  const token = $('meta[name="csrf-token"]').attr('content');
  if (token) {
    $.ajaxSetup({
      headers: { 'X-CSRF-Token': token }
    });
  }
});

// メイン機能の初期化
document.addEventListener("turbo:load", function () {
  // グローバル状態管理
  let editing = false;      // 編集モードの状態
  let hidingWord = false;   // 単語を隠すモードの状態
  let hidingMeaning = false; // 意味を隠すモードの状態

  /**
   * 編集モードの切り替え機能
   * - チェックボックスの表示/非表示
   * - 編集用UIの表示/非表示
   */
  $('#edit-mode-toggle').off().on('click', function () {
    editing = !editing; // 編集モードをトグル
    hidingWord = false; // 単語を隠すモードを無効化
    hidingMeaning = false; // 意味を隠すモードを無効化

    if (editing) {
      // 編集モードを有効化
      $('.entry-checkbox').removeClass('hidden');
      $('#edit-actions').removeClass('hidden');
      $(this).text('完了');
    } else {
      // 編集モードを無効化
      $('.entry-checkbox').addClass('hidden');
      $('#edit-actions').addClass('hidden');
      $(this).text('編集');
    }

    // 単語と意味を表示状態に戻す
    $('.word-text').removeClass('invisible');
    $('.meaning-text').removeClass('invisible');
  });

  /**
   * 単語カードのクリックイベント処理
   * - 編集モード: チェックボックスの切り替え
   * - 単語隠しモード: 単語の表示切り替え
   * - 意味隠しモード: 意味の表示切り替え
   * - 通常モード: 詳細ページへ遷移
   */
  $('.entry-card').off().on('click', function () {
    if (editing) {
      // 編集モード中はチェックボックスの選択を切り替える
      const checkbox = $(this).find('.entry-checkbox');
      checkbox.prop('checked', !checkbox.prop('checked'));
      return;
    }

    const wordText = $(this).find('.word-text'); // 単語テキスト
    const meaningText = $(this).find('.meaning-text'); // 意味テキスト

    if (hidingWord) {
      // 単語を隠すモードの処理
      if (wordText.hasClass('hidden-text')) {
        // 隠れている場合は元のテキストを表示
        wordText.text(wordText.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('font-semibold text-gray-800');
      } else {
        // 表示されている場合は「クリックして表示」に切り替え
        wordText.data('original-text', wordText.text());
        wordText.text('クリックして表示').addClass('hidden-text text-gray-400 italic').removeClass('font-semibold text-gray-800');
      }
      return;
    }

    if (hidingMeaning) {
      // 意味を隠すモードの処理
      if (meaningText.hasClass('hidden-text')) {
        // 隠れている場合は元のテキストを表示
        meaningText.text(meaningText.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('text-sm text-gray-600');
      } else {
        // 表示されている場合は「クリックして表示」に切り替え
        meaningText.data('original-text', meaningText.text());
        meaningText.text('クリックして表示').addClass('hidden-text text-gray-400 italic').removeClass('text-sm text-gray-600');
      }
      return;
    }

    // 通常のクリック時は詳細ページに遷移
    const showUrl = $(this).data('url');
    if (showUrl) {
      window.location.href = showUrl;
    }
  });

  $('.entry-checkbox').off().on('click', function (e) {
    e.stopPropagation();
  });

  /**
   * 単語を隠すボタンの機能
   * - 単語テキストを「クリックして表示」に切り替え
   * - 意味を隠すモードを解除
   * - ボタンのスタイルを切り替え
   */
  $('#toggle-word').off().on('click', function () {
    hidingWord = !hidingWord; // 単語を隠すモードをトグル
    hidingMeaning = false; // 意味を隠すモードを無効化

    // 意味を隠すボタンのスタイルをリセット
    $('#toggle-meaning').removeClass('bg-gray-600 text-white');
    $(this).toggleClass('bg-gray-600 text-white', hidingWord);

    if (hidingWord) {
      // 単語を隠す処理
      $('.word-text').each(function () {
        const $this = $(this);
        $this.data('original-text', $this.text());
        $this.text('クリックして表示').addClass('hidden-text text-gray-400 italic').removeClass('font-semibold text-gray-800');
      });

      // 意味を表示状態に戻す
      $('.meaning-text').each(function () {
        const $this = $(this);
        if ($this.hasClass('hidden-text')) {
          $this.text($this.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('text-sm text-gray-600');
        }
      });
    } else {
      // 単語を表示状態に戻す
      $('.word-text').each(function () {
        const $this = $(this);
        $this.text($this.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('font-semibold text-gray-800');
      });
    }
  });

  /**
   * 意味を隠すボタンの機能
   * - 意味テキストを「クリックして表示」に切り替え
   * - 単語を隠すモードを解除
   * - ボタンのスタイルを切り替え
   */
  $('#toggle-meaning').off().on('click', function () {
    hidingMeaning = !hidingMeaning; // 意味を隠すモードをトグル
    hidingWord = false; // 単語を隠すモードを無効化

    // 単語を隠すボタンのスタイルをリセット
    $('#toggle-word').removeClass('bg-gray-600 text-white');
    $(this).toggleClass('bg-gray-600 text-white', hidingMeaning);

    if (hidingMeaning) {
      // 意味を隠す処理
      $('.meaning-text').each(function () {
        const $this = $(this);
        $this.data('original-text', $this.text());
        $this.text('クリックして表示').addClass('hidden-text text-gray-400 italic').removeClass('text-sm text-gray-600');
      });

      // 単語を表示状態に戻す
      $('.word-text').each(function () {
        const $this = $(this);
        if ($this.hasClass('hidden-text')) {
          $this.text($this.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('font-semibold text-gray-800');
        }
      });
    } else {
      // 意味を表示状態に戻す
      $('.meaning-text').each(function () {
        const $this = $(this);
        $this.text($this.data('original-text')).removeClass('hidden-text text-gray-400 italic').addClass('text-sm text-gray-600');
      });
    }
  });

  /**
   * 単語の移動機能
   * - 選択された単語のIDを取得
   * - 移動画面へリダイレクト
   */
  $('#move-button').off().on('click', function () {
    const selectedIds = $('.entry-checkbox:checked').map(function () {
      return $(this).data('entry-id');
    }).get();

    if (selectedIds.length === 0) {
      alert('移動する単語を選択してください');
      return;
    }

    const query = $.param({ entry_ids: selectedIds });
    const moveUrl = $(this).data("move-url") + "?" + query;
    window.location.href = moveUrl;
  });

  /**
   * 単語の一括削除機能
   * - 選択された単語のIDを取得
   * - APIを使用して削除を実行
   * - 成功時はリダイレクト
   * - エラー時はアラート表示
   */
  $('#delete-button').off().on('click', function () {
    const selectedIds = $('.entry-checkbox:checked').map(function () {
      return $(this).data('entry-id');
    }).get();

    if (selectedIds.length === 0) {
      alert('削除する単語を選択してください');
      return;
    }

    if (!confirm('本当に削除しますか？')) return;

    const deleteUrl = $(this).data('delete-url');

    $.ajax({
      url: deleteUrl,
      type: 'DELETE',
      data: { entry_ids: selectedIds },
      success: function (response) {
        const url = new URL(response.redirect_url, window.location.origin);
        url.searchParams.set("notice", response.notice);
        window.location.href = url.toString();
      },
      error: function (xhr) {
        if (xhr.responseJSON?.error) {
          alert(xhr.responseJSON.error);
        } else {
          alert('削除に失敗しました');
        }
      }
    });
  });

  /**
   * 単語帳の編集モード切り替え
   * - チェックボックスの表示/非表示
   * - 編集アクションの表示/非表示
   */
  $('#edit-wordbook-mode').off().on('click', function () {
    const checkboxes = $('.wordbook-checkbox');
    const actions = $('#wordbook-edit-actions');
    const cardButtons = $('.wordbook-card-buttons');

    const isEditing = checkboxes.first().hasClass('hidden') === true;

    if (isEditing) {
      checkboxes.removeClass('hidden');
      actions.removeClass('hidden');
      cardButtons.addClass('hidden');
      $(this).text('完了');
    } else {
      checkboxes.addClass('hidden');
      actions.addClass('hidden');
      cardButtons.removeClass('hidden');
      $(this).text('編集');
    }
  });

  // === 単語帳の移動ボタン ===
  $('#wordbook-move-button').off().on('click', function () {
    const selectedIds = $('.wordbook-checkbox:checked').map(function () {
      return $(this).data('wordbook-id');
    }).get();

    if (selectedIds.length === 0) {
      alert('移動する単語帳を選択してください');
      return;
    }

    const query = $.param({ wordbook_ids: selectedIds });
    const moveUrl = $(this).data("move-url") + "?" + query;
    window.location.href = moveUrl;
  });

  // === 単語帳コピー機能 ===
  $('#copy-mode-toggle').off().on('click', function () {
    const checkboxes = $('.wordbook-copy-checkbox');
    const copyBtn = $('#copy-select-button');

    if (checkboxes.first().hasClass('hidden')) {
      checkboxes.removeClass('hidden');
      copyBtn.removeClass('hidden');
      $(this).text('キャンセル');
    } else {
      checkboxes.addClass('hidden');
      copyBtn.addClass('hidden');
      $(this).text('単語帳をコピーする');
    }
  });

  $('#copy-select-button').off().on('click', function () {
    const selectedIds = $('.wordbook-copy-checkbox:checked').map(function () {
      return $(this).data('wordbook-id');
    }).get();

    if (selectedIds.length === 0) {
      alert('コピーする単語帳を選択してください');
      return;
    }

    const query = $.param({ wordbook_ids: selectedIds });
    const copyUrl = $(this).data("copy-url") + "?" + query;
    window.location.href = copyUrl;
  });

  /**
   * UI関連の補助機能
   */
  // プロフィール画像のドロップダウンメニュー
  const avatarBtn = document.getElementById("avatar-button");
  const dropdown = document.getElementById("dropdown-menu");
  if (avatarBtn && dropdown) {
    avatarBtn.addEventListener("click", () => {
      dropdown.classList.toggle("hidden");
    });
    document.addEventListener("click", (e) => {
      if (!avatarBtn.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.classList.add("hidden");
      }
    });
  }

  // フラッシュメッセージの自動非表示
  const flash = document.querySelector(".flash-message");
  if (flash) {
    setTimeout(() => {
      flash.style.transition = "opacity 0.6s ease";
      flash.style.opacity = "0";
      setTimeout(() => {
        flash.remove();
      }, 600);
    }, 3000);
  }
});

// ブラウザのバック時にページをリロード
window.addEventListener("pageshow", function (event) {
  if (event.persisted) {
    window.location.reload();
  }
});
