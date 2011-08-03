class User < ActiveRecord::Base
  has_many :posts
  acts_as_authentic
  #acts_as_authentic serve para a autenticação de usuário com o Authlogic
end
