import { Module } from '@nestjs/common';
import { HotelsService } from './hotels.service';
import { HotelsController } from './hotels.controller';
import { SequelizeModule } from '@nestjs/sequelize';
import { hotels } from 'models/hotelSchema';
import { address, provinces } from 'models/masterSchema';

@Module({
  imports: [SequelizeModule.forFeature([hotels, provinces, address])],
  controllers: [HotelsController],
  providers: [HotelsService],
})
export class HotelsModule {}
