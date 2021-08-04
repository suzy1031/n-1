class ProfilesController < ApplicationController
  def index
    @user = User.find(1)
    raise Forbidden unless user_safe?

    @skill_categories = user_reccomend_skill_categories
    # n + 1が発生
    # 記事1つに紐づくtagsを取得 * 全記事回数SQLが発行されている
    # @articles = @user.articles
    @articles = @user.articles.preload(:tags)
  end

  private

  def user_safe?
    # @user.user_cautions.all? do |user_caution|
    #   Time.zone.now > user_caution.caution_freeze.end_time
    # end
    # 1. user_cautionsに対してjoinsメソッドを使用する事でuser_cautionsテーブルとcaution_freezesテーブルをinner joinする
    # 2. whereメソッドでcaution_freezesテーブルのend_time属性より大きいレコードのみを絞り込みSQL結果の存在確認を行う
    @user.user_cautions.joins(:caution_freeze).where("caution_freezes.end_time > ?", Time.zone.now).blank?
  end

  def user_reccomend_skill_categories
    # n + 1問題が発生
    # 1. @userに紐づくskillsを全て取得
    # 2. mapメソッドでskill毎に紐づくskill_categoryを取得
    # 3. filterメソッドでskill_categoryインスタンスのreccomend属性がtrueのインスタンスのみを取得
    # 4. 3までの実行結果である、複数のskill_categoryを要素に持つArray内のskill_categoryインスタンスを一意にしたArrayを返す
    # @user.skills.map(&:skill_category).
      # filter { |skill_category| skill_category.reccomend }.uniq

    # SkillCategoryに対してeager_loadメソッドを使用する事でSkillモデルを事前読み込みかつ、left outer joinする
    # whereメソッドでskill_categriesテーブルのreccomend属性がtrueかつskillsテーブルのuser_id属性が@user.idのレコードのみを絞り込む
      SkillCategory.eager_load(:skills).
    where(reccomend: true).
    where(skills: { user_id: @user.id })
  end
end
