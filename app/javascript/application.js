import "@hotwired/turbo-rails"
import "controllers"
import $ from "jquery"
import Rails from "@rails/ujs"
Rails.start()

$(document).on('turbo:load', function () {
  const token = $('meta[name="csrf-token"]').attr('content');
  if (token) {
    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': token
      }
    });
  }
});

document.addEventListener("turbo:load", function () {
  let editing = false;

  // 初期状態のリセット
  $('.entry-checkbox').addClass('hidden');
  $('#edit-actions').addClass('hidden');
  $('#edit-mode-toggle').text('編集');

  $('#edit-mode-toggle').off().on('click', function () {
    editing = !editing;

    if (editing) {
      $('.entry-checkbox').removeClass('hidden');
      $('#edit-actions').removeClass('hidden');
      $(this).text('完了');
    } else {
      $('.entry-checkbox').addClass('hidden');
      $('#edit-actions').addClass('hidden');
      $(this).text('編集');
    }
  });

  $('.entry-card').off().on('click', function (e) {
    const entryId = $(this).data('entry-id');
    if (editing) {
      const checkbox = $(this).find('.entry-checkbox');
      checkbox.prop('checked', !checkbox.prop('checked'));
    } else {
      const showUrl = $(this).data('url');
      if (showUrl) {
        window.location.href = showUrl;
      }
    }
  });

  $('.entry-checkbox').off().on('click', function (e) {
    e.stopPropagation();
  });

  $('#move-button').off().on('click', function () {
    const selectedIds = $('.entry-checkbox:checked').map(function () {
      return $(this).data('entry-id');
    }).get();

    if (selectedIds.length === 0) {
      alert('移動する単語を選択してください');
      return;
    }

    const query = $.param({ entry_ids: selectedIds });
    const moveUrl = $("#move-button").data("move-url") + "?" + query;
    window.location.href = moveUrl;
  });

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
        window.location.href = url.toString();  // フラッシュメッセージ付きでリダイレクト
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
});

// 戻るボタンでキャッシュが使われたときにページをリロード
window.addEventListener("pageshow", function (event) {
  if (event.persisted) {
    window.location.reload();
  }
});

document.addEventListener("turbo:load", function () {
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