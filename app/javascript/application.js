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
  // --- 単語帳編集モードの切り替え ---
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

  // --- 移動ボタン ---
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

  // --- プロフィール画像のプルダウン ---
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

  // --- フラッシュメッセージの自動非表示 ---
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