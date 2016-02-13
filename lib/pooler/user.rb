require 'bcrypt'

module Pooler
  class User < ActiveRecord::Base
    include BCrypt
    validates :username, presence:true, uniqueness:true, :length => { :in => 2..20 }
    validates :email,    presence:true, uniqueness:true, format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    has_many :picks
    has_many :payments

    def score
      picks.decided.collect(&:points).sum
    end

    def max_score
      score + picks.undecided.collect(&:points).sum
    end

    def password= password
      salt = BCrypt::Engine.generate_salt
      hash = BCrypt::Engine.hash_secret password, salt
      update! salt:salt, password_hash:hash
    end

    def login password
      password_hash == BCrypt::Engine.hash_secret(password, salt)
    end

    def lock!
      update! locked:true
    end

    def pay!
      update! paid:true
    end

    def locked?
      locked
    end

    def paid?
      paid
    end

    class << self
      def signup username, email, password
        password_salt = BCrypt::Engine.generate_salt
        password_hash = BCrypt::Engine.hash_secret password, password_salt
        User.create(
          username:      username,
          email:         email,
          salt:          password_salt.to_s,
          password_hash: password_hash.to_s)
      end
    end
  end
end
