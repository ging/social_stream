class RemoveLanguageDefault < ActiveRecord::Migration
  def up
    change_column_default('users', 'language', nil)
  end

  def down
    change_column_default('users', 'language', 'en')
  end
end
