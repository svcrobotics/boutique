class BlockchainController < ApplicationController
  def index
    @blocs = Blockchain::Service.chain.blocks
  end
end
