require 'spec_helper_controllers'

describe Gaku::TeachersController do

  let(:teacher) { create(:teacher) }
  let(:invalid_teacher) { create(:invalid_teacher) }

  context 'as admin' do
    before { as :admin }

    context 'html' do

      describe 'GET #index' do
        before do
          teacher
          gaku_get :index
        end

        it { should respond_with 200 }
        it('assigns @teachers') { expect(assigns(:teachers)).to eq [teacher] }
        it('assigns @count') { expect(assigns(:count)).to eq 1 }
        it('renders :index template') { template? :index }
      end

      describe 'GET #edit' do
        before { gaku_get :edit, id: teacher }

        it { should respond_with 200 }
        it('assigns @teacher') { expect(assigns(:teacher)).to eq teacher }
        it('renders the :edit template') { template? :edit }
      end

      describe 'GET #show' do
        before { gaku_get :show, id: teacher }

        it { should respond_with 200 }
        it('assigns @teacher') { expect(assigns(:teacher)).to eq teacher }
        it('renders the :show template') { template? :show }
      end

      describe 'PATCH #update' do
        context 'with valid attributes' do
          before do
            gaku_patch :update, id: teacher, teacher: attributes_for(:teacher, name: 'mobifon')
          end

          it { should respond_with 302 }
          it('assigns @teacher') { expect(assigns(:teacher)).to eq teacher }
          it('sets flash') { flash_updated? }
          it "changes teacher's attributes" do
            teacher.reload
            expect(teacher.name).to eq 'mobifon'
          end
        end

        context 'with invalid attributes' do
          before do
            gaku_patch :update, id: teacher, teacher: attributes_for(:invalid_teacher, name: '')
          end

          it { should respond_with 200 }
          it('assigns @teacher') { expect(assigns(:teacher)).to eq teacher }

          it "does not change teacher's attributes" do
            teacher.reload
            expect(teacher.name).not_to eq ''
          end
        end
      end

    end

    context 'js' do

      describe 'XHR GET #new' do
        before { gaku_js_get :new }

        it { should respond_with 200 }
        it('assigns @teacher') { expect(assigns(:teacher)).to be_a_new(Gaku::Teacher) }
        it('renders the :new template') { template? :new }
      end

      describe 'XHR POST #create' do
        context 'with valid attributes' do
          let(:valid_js_create) do
            gaku_js_post :create, teacher: attributes_for(:teacher)
          end

          it 'creates new teacher' do
            expect do
              valid_js_create
            end.to change(Gaku::Teacher, :count).by(1)
          end

          it 'renders flash' do
            valid_js_create
            flash_created?
          end

          it 'increments @count' do
            valid_js_create
            expect(assigns(:count)).to eq 1
          end
        end

        context 'with invalid attributes' do
          let(:invalid_js_create) do
            gaku_js_post :create, teacher: attributes_for(:invalid_teacher)
          end

          it 'does not save the new teacher' do
            expect do
              invalid_js_create
            end.to_not change(Gaku::Teacher, :count)
          end

          it 're-renders the new method' do
            invalid_js_create
            template? :create
          end

          it "doesn't increment @count" do
            invalid_js_create
            expect(assigns(:count)).to eq 0
          end
        end
      end

      describe 'XHR GET #edit' do
        before { gaku_js_get :edit, id: teacher }

        it { should respond_with 200 }
        it('assigns @teacher') { expect(assigns(:teacher)).to eq teacher }
        it('renders the :edit template') { template? :edit }
      end

      describe 'XHR DELETE #destroy' do
        it 'deletes the teacher' do
          teacher
          expect do
            gaku_js_delete :destroy, id: teacher
          end.to change(Gaku::Teacher, :count).by(-1)
        end

        it 'decrements @count' do
          gaku_js_delete :destroy, id: teacher
          expect(assigns(:count)).to eq 0
        end

        it 'sets flash' do
          gaku_js_delete :destroy, id: teacher
          flash_destroyed?
        end
      end

    end
  end

end
