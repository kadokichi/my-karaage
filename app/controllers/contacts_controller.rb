class ContactsController < ApplicationController
  before_action :build_contact, only: [:confirm, :back, :create]

  def new
    @contact = Contact.new
  end

  def confirm
    render :new, status: :unprocessable_entity if @contact.invalid?
  end

  def back
    render :new
  end

  def create
    if @contact.save
      ContactMailer.send_mail(@contact).deliver_now
      redirect_to done_contacts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def done
  end

  private

  def build_contact
    @contact = Contact.new(contact_params)
  end

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
