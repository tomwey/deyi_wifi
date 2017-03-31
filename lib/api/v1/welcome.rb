module API
  module V1
    class Welcome < Grape::API
      get :foo do
        { foo: 'bar' }
      end
    end
  end
end