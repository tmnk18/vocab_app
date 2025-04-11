require 'rails_helper'

RSpec.describe 'フォルダ管理', type: :system do
  let(:user) { create(:user) }
  
  before do
    sign_in user
  end

  describe 'フォルダの基本操作' do
    context 'フォルダ作成' do
      it '新しいフォルダを作成できること' do
        visit folders_path
        click_link '新しいフォルダを作成'
        
        fill_in 'folder[name]', with: 'テストフォルダ'
        click_button '作成'
        
        expect(page).to have_content 'フォルダを作成しました'
        expect(page).to have_content 'テストフォルダ'
      end
    end

    context 'フォルダ一覧' do
      before do
        create_list(:folder, 3, user: user)
        visit folders_path
      end

      it 'フォルダ一覧が表示されること' do
        expect(page).to have_content 'My単語帳'
        expect(page).to have_selector 'li.bg-white', count: 3
      end
    end

    context 'フォルダ削除' do
      let!(:folder) { create(:folder, user: user) }

      it 'フォルダを削除できること', js: true do
        visit folders_path
        
        accept_confirm do
          click_link '削除'
        end
        
        expect(page).to have_content 'フォルダを削除しました'
        expect(page).not_to have_content folder.name
      end
    end
  end
end
