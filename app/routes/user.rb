# frozen_string_literal: true

USER_ROUTE = proc do
  # Get all users
  get '' do
    User.auth!(request).admin!
    page = (params[:page] || 1).to_i
    size = (params[:size] || 10).to_i

    yajl :users, locals: { count: User.count,
                           page: page,
                           size: size,
                           users: User.dataset.paginate(page, size) }
  end

  # View profile
  get '/:id' do |id|
    user = User.auth!(request)
    entity = User.where(id: id)&.first
    raise NotFoundError.new("User: #{id}", 'User Not Existed') if user.nil?

    user.own!(entity)
    yajl :profile, locals: { user: entity }
  end

  # Edit profile
  put '/:id' do |id|
    user = User.auth!(request)
    entity = User.where(id: id)&.first
    raise NotFoundError.new("User: #{id}", 'User Not Existed') if user.nil?

    user.own!(entity)

    req = JSON.parse(request.body.read)
    entity.nickname = req['nickname'] unless req['nickname'].nil?
    entity.email = req['email'] unless req['email'].nil?
    entity.avatar = "user#{id}" if entity.avatar == 'default'
    entity.save

    yajl :profile, locals: { user: entity }
  end

  # Edit password
  put '/:id/password' do |id|
    user = User.auth!(request)
    entity = User.where(id: id)&.first
    raise NotFoundError.new("User: #{id}", 'User Not Existed') if user.nil?

    user.own!(entity)

    req = JSON.parse(request.body.read)
    entity.password = CryptoService.generate(req['password']) unless req['password'].nil?
    entity.save

    yajl :profile, locals: { user: entity }
  end

  # Create a delivery info
  post '/:id/delivery_infos' do |_id|
    user = User.auth!(request)

    req = JSON.parse(request.body.read)
    info = DeliveryInfo.create(
      name: req['name'],
      phone: req['phone'],
      address: req['address'],
      user: user
    )

    yajl :delivery_info, locals: {info: info}
  end

  # Update a delivery info
  put '/:id/delivery_infos/:info_id' do |id, info_id|
    user = User.auth!(request)
    info = DeliveryInfo.where(user_id: id, id: info_id)&.first
    raise NotFoundError.new("DeliveryInfo: #{info_id}", 'Delivery Info Not Existed') if info.nil?

    user.own!(info.user)

    req = JSON.parse(request.body.read)
    info.address = req['address'] unless req['address'].nil?
    info.name = req['name'] unless req['name'].nil?
    info.phone = req['phone'] unless req['phone'].nil?
    info.save

    yajl :delivery_info, locals: { info: info }
  end

  # View all delivery infos
  get '/:id/delivery_infos' do |id|
    user = User.auth!(request)
    info = DeliveryInfo.where(user_id: id)
    user.own!(info&.first.user) unless info&.first.nil?
    page = (params[:page] || 1).to_i
    size = (params[:size] || 10).to_i
    yajl :delivery_infos, locals: {
      count: info.count,
      page: page,
      size: size,
      delivery_infos: info.paginate(page, size)
    }
  end

  get '/:id/delivery_infos/:info_id' do |id, info_id|
    user = User.auth!(request)
    info = DeliveryInfo.where(user_id: id, id: info_id)&.first
    raise NotFoundError.new("DeliveryInfo: #{info_id}", 'Delivery Info Not Existed') if info.nil?
    user.own!(info.user)

    yajl :delivery_info, locals: { info: info }
  end

  # Remove a delivery info
  delete '/:id/delivery_infos/:info_id' do |id, info_id|
    user = User.auth!(request)
    info = DeliveryInfo.where(user_id: id, id: info_id)&.first
    raise NotFoundError.new("DeliveryInfo: #{info_id}", 'Delivery Info Not Existed') if info.nil?

    user.own!(info.user)
    info.delete

    yajl :empty
  end
end
