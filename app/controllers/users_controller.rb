class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  attr_accessor :target_account, :amount_transfer

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def transfer_money
    set_user
    respond_to do |format|
      
      @source_account = Account.find(@user.account.id)
      if !@source_account or @source_account.lock
        format.html { redirect_to @user, notice: 'Source doesnt exists.' }
        format.json { head :no_content }
      end

      if !Account.exists?(params[:target_account])
        format.html { redirect_to @user, notice: 'Target doesnt exists.' }
        format.json { head :no_content }
      else
        @target_account = Account.find(params[:target_account])
        if @target_account.lock
          format.html { redirect_to @user, notice: 'Target Blocked.' }
          format.json { head :no_content }
        end
      end
      @source_account.lock = true
      if !@target_account.nil?
        @target_account.lock = true

        if !@source_account.save 
          format.html { redirect_to @user, notice: 'Error blocking.' }
          format.json { head :no_content }
        end
        if !@target_account.save 
          format.html { redirect_to users_url, notice: 'Error Blocking.' }
          format.json { head :no_content }
        end
      
        initial_source = @source_account.amount
        initial_target = @target_account.amount
      
        source_amount = @source_account.amount - params[:amount_transfer].to_f
        target_amount = @target_account.amount + params[:amount_transfer].to_f
      
        @source_account.amount = source_amount
        @target_account.amount = target_amount
      
        if @source_account.save and @target_account.save
          @source_account.lock = false
          @target_account.lock = false
          @source_account.save
          @target_account.save
          format.html { redirect_to @user, notice: 'Transfer successfully.' }
          format.json { head :no_content }
        else
          #Rollback
          @source_account.amount = initial_source
          @target_account.amount = initial_target 
          @source_account.lock = false
          @target_account.lock = false
          @source_account.save
          @target_account.save

          format.html { redirect_to @user, notice: 'Transfer Error.' }
          format.json { head :no_content }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end

    
  end
