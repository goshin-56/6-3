class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true

  has_many :books, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy

  # フォローをした、されたの関係
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id"
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id"

  # 一覧画面で使う
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end


  def follow(another_user)
    unless self == another_user
      self.relationships.find_or_create_by(followed_id: another_user.id)
    end
  end

  def unfollow(another_user)
    unless self == another_user
      relationship = self.relationships.find_by(followed_id: another_user.id)
      relationship.destroy
    end
  end

  # フォローしているか判定
  def following?(another_user)
    self.followings.include?(another_user)
  end

end
