# frozen_string_literal: true

class ImagesController < ApplicationController
  def update
    cocktail = Cocktail.find(params[:id])
    if params[:file]
      # The data is a file upload coming from <input type="file" />
      cocktail.photo.attach(params[:file])
      # Generate a url for easy display on the front end
      image = url_for(cocktail.photo)
    elsif params[:camera]
      # The data is Base64 and coming from the camera.
      # Use that data to create a file for active storage.
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(Base64.decode64(params[:camera].split(',')[1])),
        filename: 'user.png',
        content_type: 'image/png'
      )
      cocktail.photo.attach(blob)
      image = url_for(cocktail.photo)
    else
      # Maybe we want to just store a url or the raw Base64 data
      image = photo_params[:photo]
    end
    # Now save that url in the cocktail
    cocktail.update(image:)

    render json: cocktail, status: :ok
  end

  def user
    user = User.find(params[:id])
    if params[:file]
      # The data is a file upload coming from <input type="file" />
      user.avatar.attach(params[:file])
      # Generate a url for easy display on the front end
      image = url_for(user.avatar)
    elsif params[:camera]
      # The data is Base64 and coming from the camera.
      # Use that data to create a file for active storage.
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(Base64.decode64(params[:camera].split(',')[1])),
        filename: 'user.png',
        content_type: 'image/png'
      )
      user.avatar.attach(blob)
      image = url_for(user.avatar)
    else
      # Maybe we want to just store a url or the raw Base64 data
      image = photo_params[:avatar]
    end
    # Now save that url in the cocktail
    user.update(profile_pic: image)

    render json: user, status: :ok
  end
end
