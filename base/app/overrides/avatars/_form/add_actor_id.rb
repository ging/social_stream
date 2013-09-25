Deface::Override.new(:virtual_path => "avatars/_form", 
                     :name => "add_actor_id", 
                     :insert_after => "code[erb-loud]:contains('form_for')", 
                     :text => "<%= hidden_field_tag 'actor_id', avatarable.id %>")
