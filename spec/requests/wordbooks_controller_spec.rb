require 'rails_helper'

RSpec.describe WordbooksController, type: :request do
  let(:user) { create(:user) }
  let(:folder) { create(:folder, user: user) }
  let(:wordbook) { create(:wordbook, folder: folder) }

  describe '単語帳の操作' do
    context 'ログイン済みの場合' do
      before { sign_in user }

      describe 'GET #index' do
        context '単語帳が存在する場合' do
          before do
            # テストデータをクリア
            folder.wordbooks.destroy_all
            
            # テストデータを作成
            @old_wordbook = create(:wordbook, 
              folder: folder, 
              title: "古い単語帳",
              created_at: 1.day.ago
            )
            
            @new_wordbook = create(:wordbook, 
              folder: folder, 
              title: "新しい単語帳",
              created_at: Time.current
            )

            get folder_wordbooks_path(folder)
          end

          it '正常なレスポンスを返すこと' do
            expect(response).to have_http_status(:ok)
          end

          it '作成日時の降順で表示されること' do
            expect(response.body).to match(/新しい単語帳.*古い単語帳/m)
          end
        end
      end

      describe 'GET #new' do
        it '新規作成フォームを表示すること' do
          get new_folder_wordbook_path(folder)
          expect(response).to have_http_status(:ok)
        end
      end

      describe 'POST #create' do
        context '有効なパラメータの場合' do
          let(:valid_params) do
            {
              wordbook: {
                title: 'テスト単語帳',
                description: '説明文',
                is_public: false
              }
            }
          end

          it '単語帳を作成すること' do
            expect {
              post folder_wordbooks_path(folder), params: valid_params
            }.to change(Wordbook, :count).by(1)
          end

          it '単語帳一覧にリダイレクトすること' do
            post folder_wordbooks_path(folder), params: valid_params
            expect(response).to redirect_to(folder_wordbooks_path(folder))
          end
        end

        context '無効なパラメータの場合' do
          let(:invalid_params) { { wordbook: { title: '' } } }

          it '単語帳を作成しないこと' do
            expect {
              post folder_wordbooks_path(folder), params: invalid_params
            }.not_to change(Wordbook, :count)
          end

          it '新規作成フォームを再表示すること' do
            post folder_wordbooks_path(folder), params: invalid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe 'DELETE #destroy' do
        let!(:wordbook_to_delete) { create(:wordbook, folder: folder) }

        context '自分の単語帳の場合' do
          it '単語帳を削除すること' do
            expect {
              delete folder_wordbook_path(folder, wordbook_to_delete)
            }.to change(Wordbook, :count).by(-1)
          end

          it '単語帳一覧にリダイレクトすること' do
            delete folder_wordbook_path(folder, wordbook_to_delete)
            expect(response).to redirect_to(folder_wordbooks_path(folder))
          end
        end

        context '他人の単語帳の場合' do
          let(:other_user) { create(:user) }
          let(:other_folder) { create(:folder, user: other_user) }
          let!(:other_wordbook) { create(:wordbook, folder: other_folder) }

          it '削除できないこと' do
            expect {
              delete folder_wordbook_path(other_folder, other_wordbook)
            }.not_to change(Wordbook, :count)
          end

          it '403エラーを返すこと' do
            delete folder_wordbook_path(other_folder, other_wordbook)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトすること' do
        get folder_wordbooks_path(folder)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #public_index' do
    let!(:public_wordbook) { create(:wordbook, folder: folder, is_public: true) }
    let!(:private_wordbook) { create(:wordbook, folder: folder, is_public: false) }

    it '公開されている単語帳のみ表示すること' do
      get public_index_wordbooks_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(public_wordbook.title)
      expect(response.body).not_to include(private_wordbook.title)
    end
  end
end