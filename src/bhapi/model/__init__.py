import sqlalchemy as sa
from sqlalchemy.ext.hybrid import hybrid_property
import sqlalchemy.orm as so
from typing import Optional, List

import datetime, uuid, math
from zoneinfo import ZoneInfo

from bhapi import default_config

# Constraint naming convention
constraint_naming_conventions = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

# Model base class
class Base(so.DeclarativeBase):
  metadata = sa.MetaData(naming_convention=constraint_naming_conventions)

# Device/Item
device_item_assoc = sa.Table(
  "device_item",
  Base.metadata,
  sa.Column("device_id", sa.ForeignKey("device.device_id"), nullable=False),
  sa.Column("item_id", sa.ForeignKey("item.item_id"), nullable=False),
  sa.PrimaryKeyConstraint("device_id", "item_id")
)

# Item/Mgroup
item_mgroup_assoc = sa.Table(
  "item_mgroup", 
  Base.metadata,
  sa.Column("item_id", sa.ForeignKey("item.item_id"), nullable=False),
  sa.Column("mgroup_id", sa.ForeignKey("mgroup.mgroup_id"), nullable=False),
  sa.PrimaryKeyConstraint("item_id", "mgroup_id")
)

# Member/Mgroup
member_mgroup_assoc = sa.Table(
  "member_mgroup", 
  Base.metadata,
  sa.Column("member_id", sa.ForeignKey("members.member_id"), nullable=False),
  sa.Column("mgroup_id", sa.ForeignKey("mgroup.mgroup_id"), nullable=False),
  sa.PrimaryKeyConstraint("member_id", "mgroup_id")
)


# Curse
class Curse(Base):
  __tablename__ = "curse"

  # Table columns
  curse_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  priority: so.Mapped[int] = so.mapped_column(default=10000)
  protect_group_cast: so.Mapped[bool] = so.mapped_column(default=True)
  protect_user_cast: so.Mapped[bool] = so.mapped_column(default=True)
  name: so.Mapped[str] = so.mapped_column(sa.String())
  display_name: so.Mapped[str] = so.mapped_column(sa.String())
  notification_markdown: so.Mapped[Optional[str]] = so.mapped_column(sa.String())

# Device
class Device(Base):
  __tablename__ = "device"

  # Table columns
  device_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  key: so.Mapped[bytes] = so.mapped_column()
  name: so.Mapped[str] = so.mapped_column(sa.String(64))
  nonce: so.Mapped[Optional[bytes]] = so.mapped_column()
  min_version: so.Mapped[int] = so.mapped_column(default=1)
  max_version: so.Mapped[int] = so.mapped_column(default=1)

  # Relationship definitions
  items: so.Mapped[List["Item"]] = so.relationship(secondary=device_item_assoc, back_populates="devices")
  vend_logs: so.Mapped[List["VendLog"]] = so.relationship(back_populates="device")

# Image
class Image(Base):
  __tablename__ = "image"

  # Table columns
  image_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  image: so.Mapped[bytes] = so.mapped_column()
  thumbnail: so.Mapped[Optional[bytes]] = so.mapped_column()
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  updated_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  content_type: so.Mapped[str] = so.mapped_column()

  # Relationship definitions
  member_image: so.Mapped["Member"] = so.relationship(back_populates="member_image")
  application_forms: so.Mapped[List["Application"]] = so.relationship(back_populates="form")
  application_pictures: so.Mapped[List["Application"]] = so.relationship(back_populates="picture")

# Item
class Item(Base):
  __tablename__ = "item"

  # Table columns
  item_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column(sa.String(32))
  display_name: so.Mapped[str] = so.mapped_column()
  scale: so.Mapped[int] = so.mapped_column(default=-1)
  unit: so.Mapped[str] = so.mapped_column(default="F")

  # Relationship definitions
  devices: so.Mapped[List["Device"]] = so.relationship(secondary=device_item_assoc, back_populates="items")
  groups: so.Mapped[List["MemberGroup"]] = so.relationship(secondary=item_mgroup_assoc, back_populates="items")
  temp_logs: so.Mapped[List["TempLog"]] = so.relationship(back_populates="item")
  access_logs: so.Mapped[List["AccessLog"]] = so.relationship(back_populates="item")

# LampColor
class LampColor(Base):
  __tablename__ = "lamp_color"

  # Table columns
  color_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()
  html_color: so.Mapped[str] = so.mapped_column(sa.String(6))

# LampPreset
class LampPreset(Base):
  __tablename__ = "lamp_preset"

  # Table columns
  preset_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()

# Log
class Log(Base):
  __tablename__ = "log"

  # Table columns
  log_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  create_time: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  type: so.Mapped[str] = so.mapped_column()
  message: so.Mapped[str] = so.mapped_column(sa.Text)

# MemberGroup
class MemberGroup(Base):
  __tablename__ = "mgroup"

  # Table columns
  mgroup_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[Optional[str]] = so.mapped_column()

  # Relationship definitions
  members: so.Mapped[List["Member"]] = so.relationship(secondary=member_mgroup_assoc, back_populates="groups")
  items: so.Mapped[List["Item"]] = so.relationship(secondary=item_mgroup_assoc, back_populates="groups")

# Panel
class Panel(Base):
  __tablename__ = "panel"

  # Table columns
  panel_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column(sa.String(32))
  title: so.Mapped[str] = so.mapped_column(sa.String(32))
  style: so.Mapped[str] = so.mapped_column(sa.String(32))
  permissions: so.Mapped[Optional[str]] = so.mapped_column(sa.String(32))
  large: so.Mapped[bool] = so.mapped_column(default=False)
  visible: so.Mapped[bool] = so.mapped_column(default=True)
  sort_order: so.Mapped[int] = so.mapped_column(default=1000)

# Session
class Session(Base):
  __tablename__ = "session"

  # Table columns
  id: so.Mapped[str] = so.mapped_column(sa.String(72), primary_key=True)
  session_data: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
  expires: so.Mapped[Optional[int]] = so.mapped_column()

# SodaType
class SodaType(Base):
  __tablename__ = "soda_type"

  # Table columns
  soda_type_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()

  # Relationship definitions
  statuses: so.Mapped[List["SodaStatus"]] = so.relationship(back_populates="soda_type")

# StorageSlotType
class StorageSlotType(Base):
  __tablename__ = "storage_slot_type"

  # Table columns
  type_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()
  can_request: so.Mapped[bool] = so.mapped_column(default=True)
  default_expire_time: so.Mapped[Optional[str]] = so.mapped_column()

  # Relationship definitions
  storage_slots: so.Mapped[List["StorageSlot"]] = so.relationship(back_populates="slot_type")

# Survey
class Survey(Base):
  __tablename__ = "survey"

  # Table columns
  survey_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  title: so.Mapped[Optional[str]] = so.mapped_column()
  name: so.Mapped[Optional[str]] = so.mapped_column()
  json_data: so.Mapped[Optional[dict]] = so.mapped_column(sa.dialects.postgresql.JSONB)

  # Relationship definitions
  survey_questions: so.Mapped[List["SurveyQuestion"]] = so.relationship(back_populates="survey")
  survey_responses: so.Mapped[List["SurveyResponse"]] = so.relationship(back_populates="survey")

# CurseAction
class CurseAction(Base):
  __tablename__ = "curse_action"

  # Table columns
  curse_action_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  curse_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("curse.curse_id"))
  path: so.Mapped[str] = so.mapped_column()
  action: so.Mapped[str] = so.mapped_column()
  message: so.Mapped[str] = so.mapped_column(sa.Text)

# Members table
class Member(Base):
  __tablename__ = "members"

  # Table columns
  fname: so.Mapped[str] = so.mapped_column(sa.String(255))
  lname: so.Mapped[str] = so.mapped_column(sa.String(255))
  phone: so.Mapped[Optional[int]] = so.mapped_column()
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  updated_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  email: so.Mapped[str] = so.mapped_column(unique=True)
  encrypted_password: so.Mapped[str] = so.mapped_column()
  handle: so.Mapped[Optional[str]] = so.mapped_column(unique=True)
  vend_credits: so.Mapped[int] = so.mapped_column(default=0)
  vend_total: so.Mapped[int] = so.mapped_column(default=0)
  door_count: so.Mapped[Optional[int]] = so.mapped_column()
  last_access: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  stripeToken: so.Mapped[Optional[str]] = so.mapped_column()
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  paypal_email: so.Mapped[Optional[str]] = so.mapped_column()
  member_image_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("image.image_id"))
  totp_secret: so.Mapped[Optional[bytes]] = so.mapped_column()
  linked_member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  alert_credits: so.Mapped[Optional[int]] = so.mapped_column()
  alert_email: so.Mapped[Optional[bool]] = so.mapped_column()
  alert_machine: so.Mapped[Optional[bool]] = so.mapped_column()

  # Relationship definitions
  member_image: so.Mapped[Optional["Image"]] = so.relationship(back_populates="member_image")
  sponsoring_member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="linked_member")
  linked_member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="sponsoring_member", remote_side=[member_id])
  groups: so.Mapped[List["MemberGroup"]] = so.relationship(secondary=member_mgroup_assoc, back_populates="members")
  purchases: so.Mapped[List["Purchase"]] = so.relationship(back_populates="member")
  reset_tokens: so.Mapped[List["ResetToken"]] = so.relationship(back_populates="member")
  storage_slots: so.Mapped[List["StorageSlot"]] = so.relationship(back_populates="member")
  survey_responses: so.Mapped[List["SurveyResponse"]] = so.relationship(back_populates="member")
  vend_logs: so.Mapped[List["VendLog"]] = so.relationship(back_populates="member")
  access_logs: so.Mapped[List["AccessLog"]] = so.relationship(back_populates="member")
  queued_actions: so.Mapped[List["Action"]] = so.relationship(back_populates="queuing_member")
  applications: so.Mapped[List["Application"]] = so.relationship(back_populates="member")
  audit_logs: so.Mapped[List["AuditLog"]] = so.relationship(back_populates="changing_member")
  badges: so.Mapped[List["Badge"]] = so.relationship(back_populates="member")
  ipn_messages: so.Mapped[List["IPNMessage"]] = so.relationship(back_populates="member")
  curses: so.Mapped[List["MemberCurse"]] = so.relationship(back_populates="member")
  panels: so.Mapped[List["MemberPanel"]] = so.relationship(back_populates="member")
  payments: so.Mapped[List["Payment"]] = so.relationship(back_populates="member")
  storage_requests: so.Mapped[List["StorageRequest"]] = so.relationship(back_populates="member")

# Purchase
class Purchase(Base):
  __tablename__ = "purchase"

  # Table columns
  purchase_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  purchased_at: so.Mapped[datetime.date] = so.mapped_column(sa.Date, default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="purchases")

# ResetToken
class ResetToken(Base):
  __tablename__ = "reset_token"

  # Table columns
  token_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  valid: so.Mapped[bool] = so.mapped_column(default=True)
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="reset_tokens")

# SodaStatus
class SodaStatus(Base):
  __tablename__ = "soda_status"

  # Table columns
  soda_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()
  sold_out: so.Mapped[bool] = so.mapped_column(default=False)
  slot_number: so.Mapped[int] = so.mapped_column()
  soda_type_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("soda_type.soda_type_id"))

  # Relationship definitions
  soda_type: so.Mapped["SodaType"] = so.relationship(back_populates="statuses")

# StorageLocation
class StorageLocation(Base):
  __tablename__ = "storage_location"

  # Table columns
  location_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  parent_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("storage_location.location_id"))
  name: so.Mapped[str] = so.mapped_column()
  sort_order: so.Mapped[int] = so.mapped_column(default=1000)

  # Relationship definitions
  parent_location: so.Mapped[Optional["StorageLocation"]] = so.relationship(back_populates="child_locations", remote_side=[location_id])
  child_locations: so.Mapped[List["StorageLocation"]] = so.relationship(back_populates="parent_location")
  storage_slots: so.Mapped[List["StorageSlot"]] = so.relationship(back_populates="location")

# StorageSlot
class StorageSlot(Base):
  __tablename__ = "storage_slot"

  # Table columns
  slot_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  name: so.Mapped[str] = so.mapped_column()
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  location_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("storage_location.location_id"))
  sort_order: so.Mapped[int] = so.mapped_column(default=1000)
  type_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("storage_slot_type.type_id"))
  expire_date: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="storage_slots")
  location: so.Mapped["StorageLocation"] = so.relationship(back_populates="storage_slots")
  slot_type: so.Mapped["StorageSlotType"] = so.relationship(back_populates="storage_slots")
  storage_requests: so.Mapped[List["StorageRequest"]] = so.relationship(back_populates="slot")

# SurveyQuestion
class SurveyQuestion(Base):
  __tablename__ = "survey_question"

  # Table columns
  survey_question_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  survey_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("survey.survey_id"))
  sort_order: so.Mapped[int] = so.mapped_column(default=1000)
  question_text: so.Mapped[str] = so.mapped_column()

  # Relationship definitions
  survey: so.Mapped["Survey"] = so.relationship(back_populates="survey_questions")
  choices: so.Mapped[List["SurveyChoice"]] = so.relationship(back_populates="survey_question")

# SurveyResponse
class SurveyResponse(Base):
  __tablename__ = "survey_response"

  # Table columns
  survey_response_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  survey_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("survey.survey_id"))
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))

  # Relationship definitions
  survey: so.Mapped["Survey"] = so.relationship(back_populates="survey_responses")
  member: so.Mapped["Member"] = so.relationship(back_populates="survey_responses")
  answers: so.Mapped[List["SurveyAnswer"]] = so.relationship(back_populates="survey_response")

# TempLog
class TempLog(Base):
  __tablename__ = "temp_log"

  # Table columns
  temp_log_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  item_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("item.item_id"))
  temperature: so.Mapped[int] = so.mapped_column()
  create_time: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))

  # Relationship definitions
  item: so.Mapped["Item"] = so.relationship(back_populates="temp_logs")

# VendLog
class VendLog(Base):
  __tablename__ = "vend_log"

  # Table columns
  vend_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  vend_time: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  device_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("device.device_id"))
  member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  vended: so.Mapped[bool] = so.mapped_column()
  badge_id: so.Mapped[Optional[int]] = so.mapped_column()

  # Relationship definitions
  device: so.Mapped["Device"] = so.relationship(back_populates="vend_logs")
  member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="vend_logs")

# AccessLog
class AccessLog(Base):
  __tablename__ = "access_log"

  # Table columns
  access_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  access_time: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  item_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("item.item_id"))
  member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  granted: so.Mapped[bool] = so.mapped_column()
  badge_id: so.Mapped[Optional[int]] = so.mapped_column()

  # Relationship definitions
  item: so.Mapped["Item"] = so.relationship(back_populates="access_logs")
  member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="access_logs")

# Action
class Action(Base):
  __tablename__ = "action"

  # Table columns
  action_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  queued_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  queuing_member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  priority: so.Mapped[int] = so.mapped_column(default=1000)
  action_type: so.Mapped[str] = so.mapped_column()
  row_id: so.Mapped[uuid.UUID] = so.mapped_column()

  # Relationship definitions
  queuing_member: so.Mapped["Member"] = so.relationship(back_populates="queued_actions")

# Application
class Application(Base):
  __tablename__ = "application"

  # Table columns
  application_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  address1: so.Mapped[str] = so.mapped_column()
  address2: so.Mapped[Optional[str]] = so.mapped_column()
  city: so.Mapped[str] = so.mapped_column()
  state: so.Mapped[Optional[str]] = so.mapped_column(sa.String(2))
  zip: so.Mapped[Optional[str]] = so.mapped_column(sa.String(9))
  contact_name: so.Mapped[Optional[str]] = so.mapped_column()
  contact_phone: so.Mapped[Optional[int]] = so.mapped_column()
  form_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("image.image_id"))
  topic_id: so.Mapped[Optional[str]] = so.mapped_column()
  picture_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("image.image_id"))
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  updated_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  app_turned_in_at: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"))
  thread_message_id: so.Mapped[Optional[str]] = so.mapped_column()
  decided_at: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"))
  final_result: so.Mapped[Optional[str]] = so.mapped_column()
  helper: so.Mapped[Optional[str]] = so.mapped_column()

  # Relationship definitions
  form: so.Mapped[Optional["Image"]] = so.relationship(back_populates="application_forms", foreign_keys="Application.form_id")
  picture: so.Mapped[Optional["Image"]] = so.relationship(back_populates="application_pictures", foreign_keys="Application.picture_id")
  member: so.Mapped["Member"] = so.relationship(back_populates="applications")

# AuditLog
class AuditLog(Base):
  __tablename__ = "audit_log"

  # Table columns
  audit_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  changing_member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  changed_member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  change_time: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  change_type: so.Mapped[str] = so.mapped_column()
  notes: so.Mapped[Optional[str]] = so.mapped_column()

  # Relationship definitions
  changing_member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="audit_logs", foreign_keys="AuditLog.changing_member_id")
  changed_member: so.Mapped["Member"] = so.relationship(foreign_keys="AuditLog.changed_member_id")

# Badge
class Badge(Base):
  __tablename__ = "badge"

  # Table columns
  badge_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  badge_number: so.Mapped[int] = so.mapped_column()
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="badges")

# IPNMessage
class IPNMessage(Base):
  __tablename__ = "ipn_message"

  # Table columns
  ipn_message_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  received_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  txn_id: so.Mapped[Optional[str]] = so.mapped_column()
  payer_email: so.Mapped[str] = so.mapped_column()
  raw: so.Mapped[str] = so.mapped_column(sa.Text)

  # Relationship definitions
  member: so.Mapped[Optional["Member"]] = so.relationship(back_populates="ipn_messages")
  payments: so.Mapped[List["Payment"]] = so.relationship(back_populates="ipn_messages")

# MemberCurse
class MemberCurse(Base):
  __tablename__ = "member_curse"

  # Table columns
  member_curse_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  curse_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("curse.curse_id"))
  issued_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  lifted_at: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"))
  issuing_member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  issuing_notes: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
  lifting_member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  lifting_notes: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="curses", foreign_keys="MemberCurse.member_id")
  curse: so.Mapped["Curse"] = so.relationship()
  issuing_member: so.Mapped["Member"] = so.relationship(foreign_keys="MemberCurse.issuing_member_id")
  lifting_member: so.Mapped[Optional["Member"]] = so.relationship(foreign_keys="MemberCurse.lifting_member_id")

# MemberPanel
class MemberPanel(Base):
  __tablename__ = "member_panel"
  __table_args__ = (
    sa.PrimaryKeyConstraint("member_id", "panel_id"),
  )

  # Table columns
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  panel_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("panel.panel_id"))
  style: so.Mapped[Optional[str]] = so.mapped_column()
  visible: so.Mapped[Optional[bool]] = so.mapped_column()
  sort_order: so.Mapped[Optional[int]] = so.mapped_column()

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="panels")
  panel: so.Mapped["Panel"] = so.relationship()

# Payment
class Payment(Base):
  __tablename__ = "payment"
  
  # Table columns
  payment_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  ipn_message_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("ipn_message.ipn_message_id"))
  payment_date: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="payments")
  ipn_message: so.Mapped["IPNMessage"] = so.relationship(back_populates="payments")

# PurchaseSoda
class PurchaseSoda(Base):
  __tablename__ = "purchase_soda"
  __table_args__ = (
    sa.PrimaryKeyConstraint("purchase_id", "soda_id"),
  )
  
  # Table columns
  purchase_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("purchase.purchase_id"))
  soda_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("soda_status.soda_id"))
  soda_quantity: so.Mapped[int] = so.mapped_column()

  # Relationship definitions
  purchase: so.Mapped["Purchase"] = so.relationship()
  soda: so.Mapped["SodaStatus"] = so.relationship()

# StorageRequest
class StorageRequest(Base):
  __tablename__ = "storage_request"

  # Table columns
  request_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  member_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("members.member_id"))
  created_at: so.Mapped[datetime.datetime] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"), default=datetime.datetime.now(tz=ZoneInfo(default_config.APP_TIMEZONE)))
  notes: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
  status: so.Mapped[str] = so.mapped_column(default="requested")
  slot_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("storage_slot.slot_id"))
  deciding_member_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("members.member_id"))
  decision_notes: so.Mapped[Optional[str]] = so.mapped_column(sa.Text)
  decided_at: so.Mapped[Optional[datetime.datetime]] = so.mapped_column(sa.DateTime().with_variant(sa.TIMESTAMP(timezone=True), "postgresql"))
  hidden: so.Mapped[bool] = so.mapped_column(default=False)
  type_id: so.Mapped[Optional[uuid.UUID]] = so.mapped_column(sa.ForeignKey("storage_slot_type.type_id"))

  # Relationship definitions
  member: so.Mapped["Member"] = so.relationship(back_populates="storage_requests", foreign_keys="StorageRequest.member_id")
  slot: so.Mapped[Optional["StorageSlot"]] = so.relationship(back_populates="storage_requests")
  deciding_member: so.Mapped[Optional["Member"]] = so.relationship(foreign_keys="StorageRequest.deciding_member_id")
  slot_type: so.Mapped[Optional["StorageSlotType"]] = so.relationship()

# SurveyAnswer
class SurveyAnswer(Base):
  __tablename__ = "survey_answer"

  # Table columns
  survey_answer_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  survey_response_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("survey_response.survey_response_id"))
  survey_question_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("survey_question.survey_question_id"))
  answer_text: so.Mapped[str] = so.mapped_column()

  # Relationship definitions
  survey_response: so.Mapped["SurveyResponse"] = so.relationship(back_populates="answers")
  survey_question: so.Mapped["SurveyQuestion"] = so.relationship()

# SurveyChoice
class SurveyChoice(Base):
  __tablename__ = "survey_choice"

  # Table columns
  survey_choice_id: so.Mapped[uuid.UUID] = so.mapped_column(primary_key=True, default=uuid.uuid4)
  survey_question_id: so.Mapped[uuid.UUID] = so.mapped_column(sa.ForeignKey("survey_question.survey_question_id"))
  sort_order: so.Mapped[int] = so.mapped_column(default=1000)
  choice_name: so.Mapped[str] = so.mapped_column()
  choice_text: so.Mapped[Optional[str]] = so.mapped_column()

  # Relationship definitions
  survey_question: so.Mapped["SurveyQuestion"] = so.relationship(back_populates="choices")

__all__ = [
  "Base",
  "Curse",
  "Device",
  "Image",
  "Item",
  "LampColor",
  "LampPreset",
  "Log",
  "MemberGroup",
  "Panel",
  "Session",
  "SodaType",
  "StorageSlotType",
  "Survey",
  "CurseAction",
  "device_item_assoc",
  "item_mgroup_assoc",
  "member_mgroup_assoc",
  "Member",
  "Purchase",
  "ResetToken",
  "SodaStatus",
  "StorageLocation",
  "StorageSlot",
  "SurveyQuestion",
  "SurveyResponse",
  "TempLog",
  "VendLog",
  "AccessLog",
  "Action",
  "Application",
  "AuditLog",
  "Badge",
  "IPNMessage",
  "MemberCurse",
  "MemberPanel",
  "Payment",
  "PurchaseSoda",
  "StorageRequest",
  "SurveyAnswer",
  "SurveyChoice",
]