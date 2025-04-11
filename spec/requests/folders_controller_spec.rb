require 'rails_helper'

RSpec.describe FoldersController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:folder) { FactoryBot.create(:folder, user: user) }

  describe 'フォルダの操作' do
    context 'ログイン済みの場合' do
      before { sign_in user }

      describe 'GET #index' do
        it 'フォルダ一覧を表示すること' do
          # 複数のフォルダを作成
          create_list(:folder, 3, user: user)
          get folders_path
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('My単語帳')
        end

        it '作成日時の降順で表示されること' do
          old_folder = create(:folder, user: user, created_at: 1.day.ago)
          new_folder = create(:folder, user: user, created_at: Time.current)
          get folders_path
          expect(response.body).to match(/#{new_folder.name}.*#{old_folder.name}/m)
        end
      end

      describe 'GET #new' do
        it '新規作成フォームを表示すること' do
          get new_folder_path
          expect(response).to have_http_status(:ok)
        end
      end

      describe 'POST #create' do
        context '有効なパラメータの場合' do
          let(:valid_params) { { folder: { name: 'テストフォルダ' } } }

          it 'フォルダを作成すること' do
            expect {
              post folders_path, params: valid_params
            }.to change(Folder, :count).by(1)
          end

          it 'フォルダ一覧にリダイレクトすること' do
            post folders_path, params: valid_params
            expect(response).to redirect_to(folders_path)
          end
        end

        context '無効なパラメータの場合' do
          let(:invalid_params) { { folder: { name: '' } } }

          it 'フォルダを作成しないこと' do
            expect {
              post folders_path, params: invalid_params
            }.not_to change(Folder, :count)
          end

          it '新規作成フォームを再表示すること' do
            post folders_path, params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe 'DELETE #destroy' do
        let!(:folder_to_delete) { create(:folder, user: user) }

        it 'フォルダを削除すること' do
          expect {
            delete folder_path(folder_to_delete)
          }.to change(Folder, :count).by(-1)
        end

        it 'フォルダ一覧にリダイレクトすること' do
          delete folder_path(folder_to_delete)
          expect(response).to redirect_to(folders_path)
        end

        context '他のユーザーのフォルダの場合' do
          let(:other_user) { create(:user) }
          let!(:other_folder) { create(:folder, user: other_user) }

          it '削除できないこと' do
            expect {
              delete folder_path(other_folder)
            }.not_to change(Folder, :count)
          end

          it '403エラーを返すこと' do
            delete folder_path(other_folder)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトすること' do
        get folders_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end