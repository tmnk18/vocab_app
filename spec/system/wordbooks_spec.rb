require 'rails_helper'

RSpec.describe '単語帳管理', type: :system do
  let(:user) { create(:user) }
  let(:folder) { create(:folder, user: user) }
  
  before do
    sign_in user
  end

  describe '単語帳の基本操作' do
    context '単語帳作成' do
      it '新しい単語帳を作成できること' do
        visit folder_wordbooks_path(folder)
        click_link '新しい単語帳を作成'
        
        fill_in 'wordbook[title]', with: 'テスト単語帳'
        fill_in 'wordbook[description]', with: '説明文'
        click_button '作成'
        
        expect(page).to have_content '単語帳を作成しました'
        expect(page).to have_content 'テスト単語帳'
      end
    end

    context '単語帳の編集と削除' do
      let!(:wordbook) { create(:wordbook, folder: folder) }

      it '単語帳の内容を更新できること' do
        visit edit_folder_wordbook_path(folder, wordbook)
        fill_in 'wordbook[title]', with: '更新後のタイトル'
        click_button '更新'
        
        expect(page).to have_content '単語帳を更新しました'
      end

      it '単語帳を削除できること', js: true do
        visit folder_wordbooks_path(folder)
        accept_confirm do
          click_link '削除'
        end
        
        expect(page).to have_content '単語帳を削除しました'
      end
    end
  end

  describe '単語の管理' do
    let!(:wordbook) { create(:wordbook, folder: folder) }

    context '単語の追加と編集' do
      it '新しい単語を追加できること' do
        visit folder_wordbook_word_entries_path(folder, wordbook)
        click_link '単語を追加'
        
        fill_in 'word_entry[word]', with: 'テスト単語'
        fill_in 'word_entry[meaning]', with: 'テストの意味'
        click_button '登録'

        expect(page).to have_content 'テスト単語'
      end

      it '単語を削除できること', js: true do
        word_entry = create(:word_entry, wordbook: wordbook)
        visit folder_wordbook_word_entries_path(folder, wordbook)
        click_button 'edit-mode-toggle'

        within(".entry-card[data-entry-id='#{word_entry.id}']") do
          find('.entry-checkbox').check
        end

        accept_confirm { click_button 'delete-button' }
        expect(page).to have_content '1件の単語を削除しました'
      end
    end
  end
end