class BullsController < ApplicationController
  before_action :set_bull, only: %i[ show edit update destroy ]

  # GET /bulls or /bulls.json
  def index
    @bulls = Bull.all
  end

  # GET /bulls/1 or /bulls/1.json
  def show
  end

  # GET /bulls/new
  def new
    @bull = Bull.new
  end

  # GET /bulls/1/edit
  def edit
  end

  # POST /bulls or /bulls.json
  def create
    @bull = Bull.new(bull_params)

    respond_to do |format|
      if @bull.save
        format.html { redirect_to bull_url(@bull), notice: "Bull was successfully created." }
        format.json { render :show, status: :created, location: @bull }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bull.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bulls/1 or /bulls/1.json
  def update
    respond_to do |format|
      if @bull.update(bull_params)
        format.html { redirect_to bull_url(@bull), notice: "Bull was successfully updated." }
        format.json { render :show, status: :ok, location: @bull }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bull.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulls/1 or /bulls/1.json
  def destroy
    @bull.destroy!

    respond_to do |format|
      format.html { redirect_to bulls_url, notice: "Bull was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bull
      @bull = Bull.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bull_params
      params.require(:bull).permit(:name, :born_on, :offspring_count)
    end
end
