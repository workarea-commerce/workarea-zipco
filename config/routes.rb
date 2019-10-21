Workarea::Storefront::Engine.routes.draw do
  get 'zipco/start/' => 'zipco#start', as: :start_zipco
  get 'zipco/complete/' => 'zipco#complete', as: :complete_zipco
  get 'zipco_landing' => 'zipco_landing#show', as: :zipco_landing
end
