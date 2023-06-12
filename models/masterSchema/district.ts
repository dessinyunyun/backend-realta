import {
  Model,
  Table,
  Column,
  DataType,
  Index,
  Sequelize,
  ForeignKey,
} from 'sequelize-typescript';

export interface districtAttributes {
  district_id?: number;
  district_name?: string;
  district_city_id?: number;
}

@Table({ tableName: 'district', schema: 'master', timestamps: false })
export class district
  extends Model<districtAttributes, districtAttributes>
  implements districtAttributes
{
  @Column({
    primaryKey: true,
    autoIncrement: true,
    type: DataType.INTEGER,
    defaultValue: Sequelize.literal(
      "nextval('master.district_district_id_seq'::regclass)",
    ),
  })
  @Index({ name: 'pk_district_id', using: 'btree', unique: true })
  district_id?: number;

  @Column({ allowNull: true, type: DataType.STRING(255) })
  district_name?: string;

  @Column({ allowNull: true, type: DataType.INTEGER })
  district_city_id?: number;
}
