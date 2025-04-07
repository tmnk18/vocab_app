import "./controllers/extraction"
import "@hotwired/turbo-rails"
import "controllers"
import $ from "jquery"
import Rails from "@rails/ujs"
Rails.start()

$(document).on('turbo:load', function () {
  const token = $('meta[name="csrf-token"]').attr('content');
  if (token) {
    $.ajaxSetup({
      headers: { 'X-CSRF-Token': token }
    });
  }
});

document.addEventListener("turbo:load", function () {
  let editing = false;
  let hidingWord = false;
  let hidingMeaning = false;

  // === 単語一覧 編集モード ===
  $('#edit-mode-toggle').off().on('click', function () {
    editing = !editing;
    hidingWord = false;
    hidingMeaning = false;

    if (editing) {
      $('.entry-checkbox').removeClass('hidden');
      $('#edit-actions').removeClass('hidden');
      $(this).text('完了');
    } else {
      $('.entry-checkbox').addClass('hidden');
      $('#edit-actions').addClass('hidden');
      $(this).text('編集');
    }

    $('.word-text').removeClass('invisible');
    $('.meaning-text').removeClass('invisible');
  });

  // === 単語カードクリック時 ===
  $('.entry-card').off().on('click', function () {
    if (editing) {
      const checkbox = $(this).find('.entry-checkbox');
      checkbox.prop('checked', !checkbox.prop('checked'));
      return;
    }

    if (hidingWord) {
      $(this).find('.word-text').toggleClass('invisible');
      return;
    }

    if (hidingMeaning) {
      $(this).find('.meaning-text').toggleClass('invisible');
      return;
    }

    const showUrl = $(this).data('url');
    if (showUrl) {
      window.location.href = showUrl;
    }
  });

  $('.entry-checkbox').off().on('click', function (e) {
    e.stopPropagation();
  });

  // === 意味／単語を隠すボタン ===
  $('#toggle-word').off().on('click', function () {
    hidingWord = !hidingWord;
    hidingMeaning = false;

    $('#toggle-meaning').removeClass('bg-gray-600 text-white');
    $(this).toggleClass('bg-gray-600 text-white', hidingWord);

    if (hidingWord) {
      $('.word-text').addClass('invisible');
      $('.meaning-text').removeClass('invisible');
    } else {
      $('.word-text').removeClass('invisible');
    }
  });

  $('#toggle-meaning').off().on('click', function () {
    hidingMeaning = !hidingMeaning;
    hidingWord = false;

    $('#toggle-word').removeClass('bg-gray-600 text-white');
    $(this).toggleClass('bg-gray-600 text-white', hidingMeaning);

    if (hidingMeaning) {
      $('.meaning-text').addClass('invisible');
      $('.word-text').removeClass('invisible');
    } else {
      $('.meaning-text').removeClass('invisible');
    }
  });

  // === 単語一覧 移動ボタン ===
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

  // === 単語一覧 削除ボタン ===
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

  // === 単語帳一覧 編集モード ===
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

  // === プロフィール画像のドロップダウン ===
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

  // === フラッシュメッセージ自動非表示 ===
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

window.addEventListener("pageshow", function (event) {
  if (event.persisted) {
    window.location.reload();
  }
});