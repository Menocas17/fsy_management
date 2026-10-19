# El tablero de cuartos: los pasillos del hotel con quién duerme en cada cuarto (participants.room), lo que hay
# que revisar a mano y quién no tiene cuarto. Lo ve todo el staff; ordenar (RoomPlansController) y configurar
# el hotel (HallwaysController) es de la dirección y el director de logística.
class RoomsController < ApplicationController
  before_action :require_rooms_viewer!
  before_action :require_company_revealed!

  def index
    @hallways = Hallway.ordered.includes(:rooms).to_a
    rooms = @hallways.flat_map(&:rooms)
    @occupants = Participant.where.not(room: [ nil, "" ]).includes(:company).order(:first_name, :last_name).group_by(&:room)
    @tiles = helpers.room_tiles_from_occupants(rooms, @occupants)
    hotel_numbers = rooms.map(&:number).to_set
    @other_rooms = @occupants.reject { |number, _| hotel_numbers.include?(number) }.sort_by { |number, _| [ number.to_i, number ] }
    @beds = rooms.reject(&:purpose_fuera_de_uso?).sum(&:capacity)
    @sleeping = rooms.sum { |room| @occupants.fetch(room.number, []).size }
    @without_room = Participant.where(room: [ nil, "" ]).order(:first_name, :last_name).to_a
    @issues = @tiles.values.select(&:issue).sort_by { |tile| [ tile.room.hallway.position, tile.room.position ] }
  end

  def show
    @room = Room.includes(:hallway).find_by!(number: params[:id])
    @occupants = @room.occupants.includes(:company).with_attached_avatar.order(:rol, :first_name, :last_name).to_a
    @tile = helpers.room_tiles_from_occupants([ @room ], { @room.number => @occupants })[@room.id]
    rooms = @room.hallway.rooms.to_a
    index = rooms.index(@room)
    @previous_room = rooms[index - 1] if index.positive?
    @next_room = rooms[index + 1]
  end
end
