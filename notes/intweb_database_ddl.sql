-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION postgres;

-- DROP TYPE public.citext;

CREATE TYPE public.citext (
	INPUT = citextin,
	OUTPUT = citextout,
	RECEIVE = citextrecv,
	SEND = citextsend,
	ALIGNMENT = 4,
	STORAGE = any,
	CATEGORY = S,
	DELIMITER = ',',
	COLLATABLE = true);
-- public.curse definition

-- Drop table

-- DROP TABLE public.curse;

CREATE TABLE public.curse (
	curse_id uuid NOT NULL,
	priority int4 DEFAULT 10000 NOT NULL,
	protect_group_cast bool DEFAULT true NOT NULL,
	protect_user_cast bool DEFAULT true NOT NULL,
	"name" varchar NOT NULL,
	display_name varchar NOT NULL,
	notification_markdown varchar NULL,
	CONSTRAINT curse_pkey PRIMARY KEY (curse_id)
);

-- public.device definition

-- Drop table

-- DROP TABLE public.device;

CREATE TABLE public.device (
	device_id uuid NOT NULL,
	"key" bytea NOT NULL,
	"name" varchar(64) NOT NULL,
	nonce bytea NULL,
	min_version int4 DEFAULT 1 NOT NULL,
	max_version int4 DEFAULT 1 NOT NULL,
	CONSTRAINT device_pkey PRIMARY KEY (device_id)
);

-- public.image definition

-- Drop table

-- DROP TABLE public.image;

CREATE TABLE public.image (
	image_id uuid NOT NULL,
	image bytea NOT NULL,
	thumbnail bytea NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	updated_at timestamptz DEFAULT now() NOT NULL,
	content_type varchar NOT NULL,
	CONSTRAINT image_pkey PRIMARY KEY (image_id)
);

-- public.item definition

-- Drop table

-- DROP TABLE public.item;

CREATE TABLE public.item (
	item_id uuid NOT NULL,
	"name" bpchar(32) NOT NULL,
	display_name varchar NOT NULL,
	"scale" int4 DEFAULT '-1'::integer NOT NULL,
	unit varchar DEFAULT (chr(176) || 'F'::text) NOT NULL,
	CONSTRAINT item_pkey PRIMARY KEY (item_id)
);

-- public.lamp_color definition

-- Drop table

-- DROP TABLE public.lamp_color;

CREATE TABLE public.lamp_color (
	color_id uuid NOT NULL,
	"name" varchar NOT NULL,
	html_color bpchar(6) NOT NULL,
	CONSTRAINT lamp_color_pkey PRIMARY KEY (color_id)
);

-- public.lamp_preset definition

-- Drop table

-- DROP TABLE public.lamp_preset;

CREATE TABLE public.lamp_preset (
	preset_id uuid NOT NULL,
	"name" varchar NOT NULL,
	CONSTRAINT lamp_preset_pkey PRIMARY KEY (preset_id)
);

-- public.log definition

-- Drop table

-- DROP TABLE public.log;

CREATE TABLE public.log (
	log_id uuid NOT NULL,
	create_time timestamptz DEFAULT now() NOT NULL,
	"type" varchar NOT NULL,
	message text NOT NULL,
	CONSTRAINT log_pkey PRIMARY KEY (log_id)
);

-- public.mgroup definition

-- Drop table

-- DROP TABLE public.mgroup;

CREATE TABLE public.mgroup (
	mgroup_id uuid NOT NULL,
	"name" varchar NULL,
	CONSTRAINT mgroup_pkey PRIMARY KEY (mgroup_id)
);

-- public.panel definition

-- Drop table

-- DROP TABLE public.panel;

CREATE TABLE public.panel (
	panel_id uuid NOT NULL,
	"name" varchar(32) NOT NULL,
	title varchar(32) NOT NULL,
	"style" varchar(32) NOT NULL,
	permissions varchar(32) NULL,
	"large" bool DEFAULT false NOT NULL,
	visible bool DEFAULT true NOT NULL,
	sort_order int4 DEFAULT 1000 NOT NULL,
	CONSTRAINT panel_pkey PRIMARY KEY (panel_id)
);

-- public."session" definition

-- Drop table

-- DROP TABLE public."session";

CREATE TABLE public."session" (
	id bpchar(72) NOT NULL,
	session_data text NULL,
	expires int4 NULL,
	CONSTRAINT sessions_pkey PRIMARY KEY (id)
);

-- public.soda_type definition

-- Drop table

-- DROP TABLE public.soda_type;

CREATE TABLE public.soda_type (
	soda_type_id uuid NOT NULL,
	"name" varchar NOT NULL,
	CONSTRAINT soda_type_pkey PRIMARY KEY (soda_type_id)
);

-- public.storage_slot_type definition

-- Drop table

-- DROP TABLE public.storage_slot_type;

CREATE TABLE public.storage_slot_type (
	type_id uuid NOT NULL,
	"name" varchar NOT NULL,
	can_request bool DEFAULT true NOT NULL,
	default_expire_time varchar NULL,
	CONSTRAINT storage_slot_type_pkey PRIMARY KEY (type_id)
);

-- public.survey definition

-- Drop table

-- DROP TABLE public.survey;

CREATE TABLE public.survey (
	survey_id uuid NOT NULL,
	title varchar NULL,
	"name" varchar NULL,
	json_data jsonb NULL,
	CONSTRAINT survey_pkey PRIMARY KEY (survey_id)
);

-- public.zry13_ipn_logdump definition

-- Drop table

-- DROP TABLE public.zry13_ipn_logdump;

CREATE TABLE public.zry13_ipn_logdump (
	filename text NULL,
	logtime timestamptz NULL,
	logmsg text NULL
);


-- public.curse_action definition

-- Drop table

-- DROP TABLE public.curse_action;

CREATE TABLE public.curse_action (
	curse_action_id uuid NOT NULL,
	curse_id uuid NOT NULL,
	"path" varchar NOT NULL,
	"action" varchar NOT NULL,
	message text NOT NULL,
	CONSTRAINT curse_action_pkey PRIMARY KEY (curse_action_id),
	CONSTRAINT curse_action_curse_id_fkey FOREIGN KEY (curse_id) REFERENCES public.curse(curse_id)
);

-- public.device_item definition

-- Drop table

-- DROP TABLE public.device_item;

CREATE TABLE public.device_item (
	device_id uuid NOT NULL,
	item_id uuid NOT NULL,
	CONSTRAINT device_item_pkey PRIMARY KEY (device_id, item_id),
	CONSTRAINT device_item_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(device_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT device_item_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- public.item_mgroup definition

-- Drop table

-- DROP TABLE public.item_mgroup;

CREATE TABLE public.item_mgroup (
	item_id uuid NOT NULL,
	mgroup_id uuid NOT NULL,
	CONSTRAINT item_mgroup_pkey PRIMARY KEY (item_id, mgroup_id),
	CONSTRAINT item_mgroup_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT item_mgroup_mgroup_id_fkey FOREIGN KEY (mgroup_id) REFERENCES public.mgroup(mgroup_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- public.lamp_bulb definition

-- Drop table

-- DROP TABLE public.lamp_bulb;

CREATE TABLE public.lamp_bulb (
	bulb_id uuid NOT NULL,
	device_id uuid NOT NULL,
	color_id uuid NOT NULL,
	slot int4 NOT NULL,
	CONSTRAINT lamp_bulb_pkey PRIMARY KEY (bulb_id),
	CONSTRAINT lamp_bulb_fk_color_id FOREIGN KEY (color_id) REFERENCES public.lamp_color(color_id) DEFERRABLE,
	CONSTRAINT lamp_bulb_fk_device_id FOREIGN KEY (device_id) REFERENCES public.device(device_id) DEFERRABLE
);
CREATE INDEX lamp_bulb_idx_color_id ON public.lamp_bulb USING btree (color_id);
CREATE INDEX lamp_bulb_idx_device_id ON public.lamp_bulb USING btree (device_id);

-- public.lamp_bulb_preset definition

-- Drop table

-- DROP TABLE public.lamp_bulb_preset;

CREATE TABLE public.lamp_bulb_preset (
	preset_id uuid NOT NULL,
	bulb_id uuid NOT NULL,
	value bool NOT NULL,
	CONSTRAINT lamp_bulb_preset_pkey PRIMARY KEY (preset_id, bulb_id),
	CONSTRAINT lamp_bulb_preset_fk_bulb_id FOREIGN KEY (bulb_id) REFERENCES public.lamp_bulb(bulb_id) DEFERRABLE,
	CONSTRAINT lamp_bulb_preset_fk_preset_id FOREIGN KEY (preset_id) REFERENCES public.lamp_preset(preset_id) DEFERRABLE
);
CREATE INDEX lamp_bulb_preset_idx_bulb_id ON public.lamp_bulb_preset USING btree (bulb_id);
CREATE INDEX lamp_bulb_preset_idx_preset_id ON public.lamp_bulb_preset USING btree (preset_id);

-- public.members definition

-- Drop table

-- DROP TABLE public.members;

CREATE TABLE public.members (
	fname varchar(255) NULL,
	lname varchar(255) NULL,
	phone int8 NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	updated_at timestamptz DEFAULT now() NOT NULL,
	email public.citext DEFAULT ''::character varying NOT NULL,
	encrypted_password varchar DEFAULT ''::character varying NOT NULL,
	handle public.citext NULL,
	vend_credits int4 DEFAULT 0 NOT NULL,
	vend_total int4 DEFAULT 0 NOT NULL,
	door_count int4 NULL,
	last_access timestamp NULL,
	"stripeToken" varchar(255) NULL,
	member_id uuid NOT NULL,
	paypal_email public.citext NULL,
	member_image_id uuid NULL,
	totp_secret bytea NULL,
	linked_member_id uuid NULL,
	alert_credits int4 NULL,
	alert_email bool NULL,
	alert_machine bool NULL,
	CONSTRAINT members_handle_key UNIQUE (handle),
	CONSTRAINT members_member_id_key UNIQUE (member_id),
	CONSTRAINT members_pkey PRIMARY KEY (member_id),
	CONSTRAINT members_linked_member_id_fkey FOREIGN KEY (linked_member_id) REFERENCES public.members(member_id),
	CONSTRAINT members_member_image_fkey FOREIGN KEY (member_image_id) REFERENCES public.image(image_id)
);
CREATE UNIQUE INDEX index_members_on_email ON public.members USING btree (email);
CREATE INDEX members_fname_lname_idx ON public.members USING btree (fname, lname);
CREATE INDEX members_lname_fname_idx ON public.members USING btree (lname, fname);

-- public.purchase definition

-- Drop table

-- DROP TABLE public.purchase;

CREATE TABLE public.purchase (
	purchase_id uuid NOT NULL,
	member_id uuid NOT NULL,
	purchased_at date DEFAULT 'now'::text::date NOT NULL,
	CONSTRAINT purchase_pkey PRIMARY KEY (purchase_id),
	CONSTRAINT purchase_fk_member_id FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX purchase_idx_member_id ON public.purchase USING btree (member_id);

-- public.reset_token definition

-- Drop table

-- DROP TABLE public.reset_token;

CREATE TABLE public.reset_token (
	token_id uuid NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	"valid" bool DEFAULT true NOT NULL,
	member_id uuid NOT NULL,
	CONSTRAINT reset_token_pkey PRIMARY KEY (token_id),
	CONSTRAINT reset_token_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id)
);

-- public.sign_in_log definition

-- Drop table

-- DROP TABLE public.sign_in_log;

CREATE TABLE public.sign_in_log (
	sign_in_id uuid NOT NULL,
	member_id uuid NULL,
	"valid" bool NOT NULL,
	sign_in_time timestamptz DEFAULT now() NOT NULL,
	remote_ip inet NOT NULL,
	email varchar NOT NULL,
	CONSTRAINT sign_in_log_pkey PRIMARY KEY (sign_in_id),
	CONSTRAINT "member" FOREIGN KEY (member_id) REFERENCES public.members(member_id)
);

-- public.soda_status definition

-- Drop table

-- DROP TABLE public.soda_status;

CREATE TABLE public.soda_status (
	soda_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	"name" varchar NOT NULL,
	sold_out bool DEFAULT false NOT NULL,
	slot_number int4 NOT NULL,
	soda_type_id uuid NOT NULL,
	CONSTRAINT soda_status_pkey PRIMARY KEY (soda_id),
	CONSTRAINT soda_status_soda_type_id_fkey FOREIGN KEY (soda_type_id) REFERENCES public.soda_type(soda_type_id)
);

-- public.storage_location definition

-- Drop table

-- DROP TABLE public.storage_location;

CREATE TABLE public.storage_location (
	location_id uuid NOT NULL,
	parent_id uuid NULL,
	"name" varchar NOT NULL,
	sort_order int4 DEFAULT 1000 NOT NULL,
	CONSTRAINT storage_location_pkey PRIMARY KEY (location_id),
	CONSTRAINT storage_location_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.storage_location(location_id)
);

-- public.storage_slot definition

-- Drop table

-- DROP TABLE public.storage_slot;

CREATE TABLE public.storage_slot (
	slot_id uuid NOT NULL,
	"name" varchar NOT NULL,
	member_id uuid NULL,
	location_id uuid NOT NULL,
	sort_order int4 DEFAULT 1000 NOT NULL,
	type_id uuid NOT NULL,
	expire_date timestamptz NULL,
	CONSTRAINT storage_pkey PRIMARY KEY (slot_id),
	CONSTRAINT storage_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id),
	CONSTRAINT storage_slot_fk_type_id FOREIGN KEY (type_id) REFERENCES public.storage_slot_type(type_id),
	CONSTRAINT storage_storage_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.storage_location(location_id)
);
CREATE INDEX storage_slot_idx_type_id ON public.storage_slot USING btree (type_id);

-- public.survey_question definition

-- Drop table

-- DROP TABLE public.survey_question;

CREATE TABLE public.survey_question (
	survey_question_id uuid NOT NULL,
	survey_id uuid NOT NULL,
	sort_order int4 DEFAULT 1000 NOT NULL,
	question_text varchar NOT NULL,
	CONSTRAINT survey_question_pkey PRIMARY KEY (survey_question_id),
	CONSTRAINT survey_question_fk_survey_id FOREIGN KEY (survey_id) REFERENCES public.survey(survey_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX survey_question_idx_survey_id ON public.survey_question USING btree (survey_id);

-- public.survey_response definition

-- Drop table

-- DROP TABLE public.survey_response;

CREATE TABLE public.survey_response (
	survey_response_id uuid NOT NULL,
	survey_id uuid NOT NULL,
	member_id uuid NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT survey_response_pkey PRIMARY KEY (survey_response_id),
	CONSTRAINT survey_response_fk_member_id FOREIGN KEY (member_id) REFERENCES public.members(member_id) DEFERRABLE,
	CONSTRAINT survey_response_fk_survey_id FOREIGN KEY (survey_id) REFERENCES public.survey(survey_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE
);
CREATE INDEX survey_response_idx_member_id ON public.survey_response USING btree (member_id);
CREATE INDEX survey_response_idx_survey_id ON public.survey_response USING btree (survey_id);

-- public.temp_log definition

-- Drop table

-- DROP TABLE public.temp_log;

CREATE TABLE public.temp_log (
	temp_log_id uuid NOT NULL,
	item_id uuid NOT NULL,
	temperature int4 NOT NULL,
	create_time timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT temperature_pkey PRIMARY KEY (temp_log_id),
	CONSTRAINT temperature_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX recent_temp ON public.temp_log USING btree (item_id, create_time);

-- public.vend_log definition

-- Drop table

-- DROP TABLE public.vend_log;

CREATE TABLE public.vend_log (
	vend_id uuid NOT NULL,
	vend_time timestamptz DEFAULT now() NOT NULL,
	device_id uuid NOT NULL,
	member_id uuid NULL,
	vended bool NOT NULL,
	badge_id int4 NULL,
	CONSTRAINT vend_log_pkey PRIMARY KEY (vend_id),
	CONSTRAINT vend_log_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(device_id),
	CONSTRAINT vend_log_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id)
);

-- public.access_log definition

-- Drop table

-- DROP TABLE public.access_log;

CREATE TABLE public.access_log (
	access_id uuid NOT NULL,
	access_time timestamptz DEFAULT now() NOT NULL,
	item_id uuid NOT NULL,
	member_id uuid NULL,
	"granted" bool NOT NULL,
	badge_id int4 NULL,
	CONSTRAINT access_log_pkey PRIMARY KEY (access_id),
	CONSTRAINT access_log_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT access_log_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX access_log_member_id_access_time_idx ON public.access_log USING btree (member_id, access_time);
CREATE INDEX recent ON public.access_log USING btree (access_time);

-- public."action" definition

-- Drop table

-- DROP TABLE public."action";

CREATE TABLE public."action" (
	action_id uuid NOT NULL,
	queued_at timestamptz DEFAULT now() NOT NULL,
	queuing_member_id uuid NOT NULL,
	priority int4 DEFAULT 1000 NOT NULL,
	action_type varchar NOT NULL,
	row_id uuid NOT NULL,
	CONSTRAINT action_pkey PRIMARY KEY (action_id),
	CONSTRAINT action_queuing_member_id_fkey FOREIGN KEY (queuing_member_id) REFERENCES public.members(member_id)
);

-- public.application definition

-- Drop table

-- DROP TABLE public.application;

CREATE TABLE public.application (
	application_id uuid NOT NULL,
	address1 varchar NOT NULL,
	address2 varchar NULL,
	city varchar NOT NULL,
	state bpchar(2) NULL,
	zip bpchar(9) NULL,
	contact_name varchar NULL,
	contact_phone int8 NULL,
	form_id uuid NULL,
	topic_id varchar NULL,
	picture_id uuid NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	updated_at timestamptz DEFAULT now() NOT NULL,
	member_id uuid NOT NULL,
	app_turned_in_at timestamptz NULL,
	thread_message_id varchar NULL,
	decided_at timestamptz NULL,
	final_result varchar NULL,
	helper varchar NULL,
	CONSTRAINT application_pkey PRIMARY KEY (application_id),
	CONSTRAINT application_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.image(image_id),
	CONSTRAINT application_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id),
	CONSTRAINT application_picture_id_fkey FOREIGN KEY (picture_id) REFERENCES public.image(image_id)
);

-- public.audit_log definition

-- Drop table

-- DROP TABLE public.audit_log;

CREATE TABLE public.audit_log (
	audit_id uuid NOT NULL,
	changing_member_id uuid NULL,
	changed_member_id uuid NOT NULL,
	change_time timestamptz(6) DEFAULT now() NOT NULL,
	change_type varchar NOT NULL,
	notes varchar NULL,
	CONSTRAINT audit_log_pkey PRIMARY KEY (audit_id),
	CONSTRAINT audit_log_changed_member_id_fkey FOREIGN KEY (changed_member_id) REFERENCES public.members(member_id),
	CONSTRAINT audit_log_changing_member_id_fkey FOREIGN KEY (changing_member_id) REFERENCES public.members(member_id)
);

-- public.badge definition

-- Drop table

-- DROP TABLE public.badge;

CREATE TABLE public.badge (
	badge_id uuid NOT NULL,
	badge_number int4 NOT NULL,
	member_id uuid NOT NULL,
	CONSTRAINT badge_pkey PRIMARY KEY (badge_id),
	CONSTRAINT badge_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- public.ipn_message definition

-- Drop table

-- DROP TABLE public.ipn_message;

CREATE TABLE public.ipn_message (
	ipn_message_id uuid NOT NULL,
	member_id uuid NULL,
	received_at timestamptz DEFAULT now() NOT NULL,
	txn_id varchar NULL,
	payer_email varchar NOT NULL,
	raw text NOT NULL,
	CONSTRAINT ipn_message_pkey PRIMARY KEY (ipn_message_id),
	CONSTRAINT ipn_message_fk_member_id FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX ipn_message_idx_member_id ON public.ipn_message USING btree (member_id);

-- public.member_curse definition

-- Drop table

-- DROP TABLE public.member_curse;

CREATE TABLE public.member_curse (
	member_curse_id uuid NOT NULL,
	member_id uuid NOT NULL,
	curse_id uuid NOT NULL,
	issued_at timestamptz DEFAULT now() NOT NULL,
	lifted_at timestamptz NULL,
	issuing_member_id uuid NOT NULL,
	issuing_notes text NULL,
	lifting_member_id uuid NULL,
	lifting_notes text NULL,
	CONSTRAINT member_curse_pkey PRIMARY KEY (member_curse_id),
	CONSTRAINT member_curse_curse_id_fkey FOREIGN KEY (curse_id) REFERENCES public.curse(curse_id),
	CONSTRAINT member_curse_issuing_member_id_fkey FOREIGN KEY (issuing_member_id) REFERENCES public.members(member_id),
	CONSTRAINT member_curse_lifting_member_id_fkey FOREIGN KEY (lifting_member_id) REFERENCES public.members(member_id),
	CONSTRAINT member_curse_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id)
);

-- public.member_mgroup definition

-- Drop table

-- DROP TABLE public.member_mgroup;

CREATE TABLE public.member_mgroup (
	member_id uuid NOT NULL,
	mgroup_id uuid NOT NULL,
	CONSTRAINT member_mgroup_pkey PRIMARY KEY (member_id, mgroup_id),
	CONSTRAINT member_mgroup_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT member_mgroup_mgroup_id_fkey FOREIGN KEY (mgroup_id) REFERENCES public.mgroup(mgroup_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- public.member_panel definition

-- Drop table

-- DROP TABLE public.member_panel;

CREATE TABLE public.member_panel (
	member_id uuid NOT NULL,
	panel_id uuid NOT NULL,
	"style" varchar NULL,
	visible bool NULL,
	sort_order int4 NULL,
	CONSTRAINT member_panel_pkey PRIMARY KEY (member_id, panel_id),
	CONSTRAINT member_panel_fk_member_id FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT member_panel_fk_panel_id FOREIGN KEY (panel_id) REFERENCES public.panel(panel_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX member_panel_idx_member_id ON public.member_panel USING btree (member_id);
CREATE INDEX member_panel_idx_panel_id ON public.member_panel USING btree (panel_id);

-- public.payment definition

-- Drop table

-- DROP TABLE public.payment;

CREATE TABLE public.payment (
	payment_id uuid NOT NULL,
	member_id uuid NOT NULL,
	ipn_message_id uuid NOT NULL,
	payment_date timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT payment_pkey PRIMARY KEY (payment_id),
	CONSTRAINT payment_fk_ipn_message_id FOREIGN KEY (ipn_message_id) REFERENCES public.ipn_message(ipn_message_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT payment_fk_member_id FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX payment_idx_ipn_message_id ON public.payment USING btree (ipn_message_id);
CREATE INDEX payment_idx_member_id ON public.payment USING btree (member_id);

-- public.purchase_soda definition

-- Drop table

-- DROP TABLE public.purchase_soda;

CREATE TABLE public.purchase_soda (
	purchase_id uuid NOT NULL,
	soda_id uuid NOT NULL,
	soda_quantity int4 NOT NULL,
	CONSTRAINT purchase_soda_pkey PRIMARY KEY (purchase_id, soda_id),
	CONSTRAINT purchase_soda_fk_purchase_id FOREIGN KEY (purchase_id) REFERENCES public.purchase(purchase_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT purchase_soda_fk_soda_id FOREIGN KEY (soda_id) REFERENCES public.soda_status(soda_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX purchase_soda_idx_purchase_id ON public.purchase_soda USING btree (purchase_id);
CREATE INDEX purchase_soda_idx_soda_id ON public.purchase_soda USING btree (soda_id);

-- public.storage_request definition

-- Drop table

-- DROP TABLE public.storage_request;

CREATE TABLE public.storage_request (
	request_id uuid NOT NULL,
	member_id uuid NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	notes text NULL,
	status varchar DEFAULT 'requested'::character varying NOT NULL,
	slot_id uuid NULL,
	deciding_member_id uuid NULL,
	decision_notes text NULL,
	decided_at timestamptz NULL,
	hidden bool DEFAULT false NOT NULL,
	type_id uuid NULL,
	CONSTRAINT storage_request_pkey PRIMARY KEY (request_id),
	CONSTRAINT storage_request_deciding_member_id_fkey FOREIGN KEY (deciding_member_id) REFERENCES public.members(member_id),
	CONSTRAINT storage_request_fk_type_id FOREIGN KEY (type_id) REFERENCES public.storage_slot_type(type_id),
	CONSTRAINT storage_request_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id),
	CONSTRAINT storage_request_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.storage_slot(slot_id)
);
CREATE INDEX storage_request_idx_type_id ON public.storage_request USING btree (type_id);

-- public.survey_answer definition

-- Drop table

-- DROP TABLE public.survey_answer;

CREATE TABLE public.survey_answer (
	survey_answer_id uuid NOT NULL,
	survey_response_id uuid NOT NULL,
	survey_question_id uuid NOT NULL,
	answer_text varchar NOT NULL,
	CONSTRAINT survey_answer_pkey PRIMARY KEY (survey_answer_id),
	CONSTRAINT survey_answer_fk_survey_question_id FOREIGN KEY (survey_question_id) REFERENCES public.survey_question(survey_question_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT survey_answer_fk_survey_response_id FOREIGN KEY (survey_response_id) REFERENCES public.survey_response(survey_response_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX survey_answer_idx_survey_question_id ON public.survey_answer USING btree (survey_question_id);
CREATE INDEX survey_answer_idx_survey_response_id ON public.survey_answer USING btree (survey_response_id);

-- public.survey_choice definition

-- Drop table

-- DROP TABLE public.survey_choice;

CREATE TABLE public.survey_choice (
	survey_choice_id uuid NOT NULL,
	survey_question_id uuid NOT NULL,
	sort_order int4 DEFAULT 1000 NOT NULL,
	choice_name varchar NOT NULL,
	choice_text varchar NULL,
	CONSTRAINT survey_choice_pkey PRIMARY KEY (survey_choice_id),
	CONSTRAINT survey_choice_fk_survey_question_id FOREIGN KEY (survey_question_id) REFERENCES public.survey_question(survey_question_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX survey_choice_idx_survey_question_id ON public.survey_choice USING btree (survey_question_id);

-- public.v_access_history source

CREATE OR REPLACE VIEW public.v_access_history
AS WITH slots AS (
         SELECT ss.member_id,
            string_agg(ss.name::text, ', '::text) AS slots
           FROM storage_slot ss
          WHERE ss.member_id IS NOT NULL
          GROUP BY ss.member_id
        ), access_data AS (
         SELECT m.member_id,
            m.fname,
            m.lname,
                CASE
                    WHEN m.linked_member_id IS NULL THEN 0
                    ELSE 1
                END AS is_plusone,
            i.name AS item_name,
            al.access_time,
            date_part('year'::text, al.access_time) AS access_year,
            date_part('month'::text, al.access_time) AS access_month,
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision THEN 1
                    ELSE 0
                END AS "2026",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision THEN 1
                    ELSE 0
                END AS "2025",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision THEN 1
                    ELSE 0
                END AS "2024",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision THEN 1
                    ELSE 0
                END AS "2023",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 12::double precision THEN 1
                    ELSE 0
                END AS "2026-12",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 11::double precision THEN 1
                    ELSE 0
                END AS "2026-11",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 10::double precision THEN 1
                    ELSE 0
                END AS "2026-10",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 9::double precision THEN 1
                    ELSE 0
                END AS "2026-09",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 8::double precision THEN 1
                    ELSE 0
                END AS "2026-08",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 7::double precision THEN 1
                    ELSE 0
                END AS "2026-07",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 6::double precision THEN 1
                    ELSE 0
                END AS "2026-06",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 5::double precision THEN 1
                    ELSE 0
                END AS "2026-05",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 4::double precision THEN 1
                    ELSE 0
                END AS "2026-04",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 3::double precision THEN 1
                    ELSE 0
                END AS "2026-03",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 2::double precision THEN 1
                    ELSE 0
                END AS "2026-02",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2026::double precision AND date_part('month'::text, al.access_time) = 1::double precision THEN 1
                    ELSE 0
                END AS "2026-01",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 12::double precision THEN 1
                    ELSE 0
                END AS "2025-12",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 11::double precision THEN 1
                    ELSE 0
                END AS "2025-11",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 10::double precision THEN 1
                    ELSE 0
                END AS "2025-10",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 9::double precision THEN 1
                    ELSE 0
                END AS "2025-09",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 8::double precision THEN 1
                    ELSE 0
                END AS "2025-08",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 7::double precision THEN 1
                    ELSE 0
                END AS "2025-07",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 6::double precision THEN 1
                    ELSE 0
                END AS "2025-06",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 5::double precision THEN 1
                    ELSE 0
                END AS "2025-05",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 4::double precision THEN 1
                    ELSE 0
                END AS "2025-04",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 3::double precision THEN 1
                    ELSE 0
                END AS "2025-03",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 2::double precision THEN 1
                    ELSE 0
                END AS "2025-02",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2025::double precision AND date_part('month'::text, al.access_time) = 1::double precision THEN 1
                    ELSE 0
                END AS "2025-01",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 12::double precision THEN 1
                    ELSE 0
                END AS "2024-12",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 11::double precision THEN 1
                    ELSE 0
                END AS "2024-11",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 10::double precision THEN 1
                    ELSE 0
                END AS "2024-10",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 9::double precision THEN 1
                    ELSE 0
                END AS "2024-09",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 8::double precision THEN 1
                    ELSE 0
                END AS "2024-08",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 7::double precision THEN 1
                    ELSE 0
                END AS "2024-07",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 6::double precision THEN 1
                    ELSE 0
                END AS "2024-06",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 5::double precision THEN 1
                    ELSE 0
                END AS "2024-05",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 4::double precision THEN 1
                    ELSE 0
                END AS "2024-04",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 3::double precision THEN 1
                    ELSE 0
                END AS "2024-03",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 2::double precision THEN 1
                    ELSE 0
                END AS "2024-02",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2024::double precision AND date_part('month'::text, al.access_time) = 1::double precision THEN 1
                    ELSE 0
                END AS "2024-01",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 12::double precision THEN 1
                    ELSE 0
                END AS "2023-12",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 11::double precision THEN 1
                    ELSE 0
                END AS "2023-11",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 10::double precision THEN 1
                    ELSE 0
                END AS "2023-10",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 9::double precision THEN 1
                    ELSE 0
                END AS "2023-09",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 8::double precision THEN 1
                    ELSE 0
                END AS "2023-08",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 7::double precision THEN 1
                    ELSE 0
                END AS "2023-07",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 6::double precision THEN 1
                    ELSE 0
                END AS "2023-06",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 5::double precision THEN 1
                    ELSE 0
                END AS "2023-05",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 4::double precision THEN 1
                    ELSE 0
                END AS "2023-04",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 3::double precision THEN 1
                    ELSE 0
                END AS "2023-03",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 2::double precision THEN 1
                    ELSE 0
                END AS "2023-02",
                CASE
                    WHEN date_part('year'::text, al.access_time) = 2023::double precision AND date_part('month'::text, al.access_time) = 1::double precision THEN 1
                    ELSE 0
                END AS "2023-01"
           FROM access_log al
             LEFT JOIN item i ON al.item_id = i.item_id
             LEFT JOIN members m ON al.member_id = m.member_id
             LEFT JOIN slots s_1 ON m.member_id = s_1.member_id
          WHERE (al.member_id IN ( SELECT m_1.member_id
                   FROM members m_1
                     LEFT JOIN member_mgroup mm ON m_1.member_id = mm.member_id
                     LEFT JOIN mgroup m2 ON mm.mgroup_id = m2.mgroup_id
                  WHERE m2.name::text = 'members'::text))
        )
 SELECT ad.fname,
    ad.lname,
    ad.is_plusone,
    now()::date - max(ad.access_time)::date AS days_since_last_access,
    max(ad.access_time)::date AS last_access,
    sum(ad."2026") AS "2026",
    sum(ad."2025") AS "2025",
    sum(ad."2024") AS "2024",
    sum(ad."2023") AS "2023",
    s.slots,
    sum(ad."2026-12") AS "2026-12",
    sum(ad."2026-11") AS "2026-11",
    sum(ad."2026-10") AS "2026-10",
    sum(ad."2026-09") AS "2026-09",
    sum(ad."2026-08") AS "2026-08",
    sum(ad."2026-07") AS "2026-07",
    sum(ad."2026-06") AS "2026-06",
    sum(ad."2026-05") AS "2026-05",
    sum(ad."2026-04") AS "2026-04",
    sum(ad."2026-03") AS "2026-03",
    sum(ad."2026-02") AS "2026-02",
    sum(ad."2026-01") AS "2026-01",
    sum(ad."2025-12") AS "2025-12",
    sum(ad."2025-11") AS "2025-11",
    sum(ad."2025-10") AS "2025-10",
    sum(ad."2025-09") AS "2025-09",
    sum(ad."2025-08") AS "2025-08",
    sum(ad."2025-07") AS "2025-07",
    sum(ad."2025-06") AS "2025-06",
    sum(ad."2025-05") AS "2025-05",
    sum(ad."2025-04") AS "2025-04",
    sum(ad."2025-03") AS "2025-03",
    sum(ad."2025-02") AS "2025-02",
    sum(ad."2025-01") AS "2025-01",
    sum(ad."2024-12") AS "2024-12",
    sum(ad."2024-11") AS "2024-11",
    sum(ad."2024-10") AS "2024-10",
    sum(ad."2024-09") AS "2024-09",
    sum(ad."2024-08") AS "2024-08",
    sum(ad."2024-07") AS "2024-07",
    sum(ad."2024-06") AS "2024-06",
    sum(ad."2024-05") AS "2024-05",
    sum(ad."2024-04") AS "2024-04",
    sum(ad."2024-03") AS "2024-03",
    sum(ad."2024-02") AS "2024-02",
    sum(ad."2024-01") AS "2024-01",
    sum(ad."2023-12") AS "2023-12",
    sum(ad."2023-11") AS "2023-11",
    sum(ad."2023-10") AS "2023-10",
    sum(ad."2023-09") AS "2023-09",
    sum(ad."2023-08") AS "2023-08",
    sum(ad."2023-07") AS "2023-07",
    sum(ad."2023-06") AS "2023-06",
    sum(ad."2023-05") AS "2023-05",
    sum(ad."2023-04") AS "2023-04",
    sum(ad."2023-03") AS "2023-03",
    sum(ad."2023-02") AS "2023-02",
    sum(ad."2023-01") AS "2023-01"
   FROM access_data ad
     LEFT JOIN slots s ON ad.member_id = s.member_id
  GROUP BY ad.member_id, ad.fname, ad.lname, ad.is_plusone, s.slots
  ORDER BY (now()::date - max(ad.access_time)::date) DESC;


-- public.v_audit_log source

CREATE OR REPLACE VIEW public.v_audit_log
AS SELECT a.change_type,
    (changer.fname::text || ' '::text) || changer.lname::text AS changing_member,
    (changed.fname::text || ' '::text) || changed.lname::text AS changed_member,
        CASE
            WHEN a.change_type::text ~~ '%group%'::text AND (regexp_match(a.notes::text, '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'::text))[1] IS NOT NULL THEN regexp_replace(a.notes::text, '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'::text, ('['::text || g.name::text) || ']'::text)::character varying
            ELSE a.notes
        END AS friendly_notes,
    a.change_time,
    a.audit_id,
    a.changing_member_id,
    a.changed_member_id,
    g.mgroup_id,
    g.name AS mgroup_name,
    a.notes
   FROM audit_log a
     LEFT JOIN members changer ON a.changing_member_id = changer.member_id
     LEFT JOIN members changed ON a.changed_member_id = changed.member_id
     LEFT JOIN mgroup g ON (regexp_match(a.notes::text, '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'::text))[1] = g.mgroup_id::character varying::text
  ORDER BY a.change_time DESC;


-- public.v_duplicate_members source

CREATE OR REPLACE VIEW public.v_duplicate_members
AS WITH dupes AS (
         SELECT members.fname,
            members.lname,
            count(*) AS dupe_count
           FROM members
          GROUP BY members.fname, members.lname
         HAVING count(*) > 1
        )
 SELECT g.name AS group_name,
    m.fname,
    m.lname,
    m.phone,
    m.created_at,
    m.updated_at,
    m.email,
    m.encrypted_password,
    m.handle,
    m.vend_credits,
    m.vend_total,
    m.door_count,
    m.last_access,
    m."stripeToken",
    m.member_id,
    m.paypal_email,
    m.member_image_id,
    m.totp_secret,
    m.linked_member_id,
    m.alert_credits,
    m.alert_email,
    m.alert_machine
   FROM members m
     LEFT JOIN member_mgroup mg ON m.member_id = mg.member_id
     LEFT JOIN mgroup g ON mg.mgroup_id = g.mgroup_id
     JOIN dupes d ON m.fname::text = d.fname::text AND m.lname::text = d.lname::text
  ORDER BY m.fname, m.lname;


-- public.v_member_payment_history source

CREATE OR REPLACE VIEW public.v_member_payment_history
AS WITH member_payment_history AS (
         SELECT p.member_id,
            m.fname,
            m.lname,
            m.created_at::date AS created,
            li.latest_txn_type,
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 12::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-12",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 11::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-11",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 10::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-10",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 9::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-09",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 8::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-08",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 7::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-07",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 6::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-06",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 5::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-05",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 4::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-04",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 3::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-03",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 2::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-02",
            max(
                CASE
                    WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 1::double precision THEN p.payment_date
                    ELSE NULL::timestamp with time zone
                END)::date AS "2024-01"
           FROM payment p
             LEFT JOIN members m ON p.member_id = m.member_id
             LEFT JOIN v_members_latest_ipn li ON p.member_id = li.member_id
          WHERE p.payment_date >= '2024-01-01 00:00:00-05'::timestamp with time zone
          GROUP BY p.member_id, m.fname, m.lname, (m.created_at::date), li.latest_txn_type
        )
 SELECT member_payment_history.member_id,
    member_payment_history.fname,
    member_payment_history.lname,
    member_payment_history.created,
    member_payment_history.latest_txn_type,
    member_payment_history."2024-12",
    member_payment_history."2024-11",
    member_payment_history."2024-10",
    member_payment_history."2024-09",
    member_payment_history."2024-08",
    member_payment_history."2024-07",
    member_payment_history."2024-06",
    member_payment_history."2024-05",
    member_payment_history."2024-04",
    member_payment_history."2024-03",
    member_payment_history."2024-02",
    member_payment_history."2024-01"
   FROM member_payment_history
  ORDER BY (
        CASE
            WHEN member_payment_history."2024-12" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-12"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-11" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-11"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-10" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-10"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-09" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-09"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-08" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-08"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-07" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-07"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-06" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-06"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-05" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-05"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-04" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-04"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-03" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-03"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-02" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-02"
        END) DESC, (
        CASE
            WHEN member_payment_history."2024-01" IS NULL THEN '2100-01-01'::date
            ELSE member_payment_history."2024-01"
        END) DESC;


-- public.v_members_active source

CREATE OR REPLACE VIEW public.v_members_active
AS WITH active_members AS (
         SELECT m.member_id,
            m.fname,
            m.lname,
            m.email
           FROM members m
             LEFT JOIN member_mgroup mg ON m.member_id = mg.member_id
             LEFT JOIN mgroup g ON mg.mgroup_id = g.mgroup_id
          WHERE g.name::text = 'members'::text
        ), last_access AS (
         SELECT access_log.member_id,
            max(access_log.access_time) AS max_access
           FROM access_log
          WHERE access_log.granted = true
          GROUP BY access_log.member_id
        )
 SELECT am.fname,
    am.lname,
    am.email,
    la.max_access,
    date_part('day'::text, now() - la.max_access) AS date_part,
        CASE
            WHEN date_part('day'::text, now() - la.max_access) > 90::double precision THEN 1
            ELSE 0
        END AS last_90
   FROM active_members am
     LEFT JOIN last_access la ON am.member_id = la.member_id;


-- public.v_members_expiring source

CREATE OR REPLACE VIEW public.v_members_expiring
AS WITH expired_users AS (
         SELECT al.change_time,
            al.changed_member_id,
            al.changing_member_id,
            al.change_type,
            split_part(al.notes::text, ' '::text, 3)::uuid AS group_id,
            al.notes
           FROM audit_log al
          WHERE al.notes::text ~~ '%lapsed%'::text AND al.change_time >= '2024-01-01 00:00:00-05'::timestamp with time zone
          ORDER BY al.change_time DESC
        )
 SELECT eu.change_time,
    eu.change_type,
    mg.name AS group_name,
    cm.lname AS changed_by,
    m.fname,
    m.lname,
    m.email,
    m.paypal_email,
    eu.notes,
    m.last_access,
    eu.changed_member_id
   FROM expired_users eu
     LEFT JOIN members m ON eu.changed_member_id = m.member_id
     LEFT JOIN members cm ON eu.changing_member_id = cm.member_id
     LEFT JOIN mgroup mg ON eu.group_id = mg.mgroup_id;


-- public.v_members_latest_ipn source

CREATE OR REPLACE VIEW public.v_members_latest_ipn
AS WITH latest_ipn AS (
         SELECT im_1.member_id,
            max(im_1.received_at) AS received_at
           FROM ipn_message im_1
          WHERE im_1.member_id IS NOT NULL
          GROUP BY im_1.member_id
        )
 SELECT li.member_id,
    li.received_at,
    (im.raw::json -> 'txn_type'::text)::character varying AS latest_txn_type,
    im.ipn_message_id
   FROM latest_ipn li
     LEFT JOIN ipn_message im ON li.member_id = im.member_id AND li.received_at = im.received_at;


-- public.v_members_pending_cancellation source

CREATE OR REPLACE VIEW public.v_members_pending_cancellation
AS SELECT v_member_payment_history.member_id,
    v_member_payment_history.fname,
    v_member_payment_history.lname,
    v_member_payment_history.created,
    v_member_payment_history.latest_txn_type,
    v_member_payment_history."2024-12",
    v_member_payment_history."2024-11",
    v_member_payment_history."2024-10",
    v_member_payment_history."2024-09",
    v_member_payment_history."2024-08",
    v_member_payment_history."2024-07",
    v_member_payment_history."2024-06",
    v_member_payment_history."2024-05",
    v_member_payment_history."2024-04",
    v_member_payment_history."2024-03",
    v_member_payment_history."2024-02",
    v_member_payment_history."2024-01"
   FROM v_member_payment_history
  WHERE (v_member_payment_history.member_id IN ( SELECT v_members_expiring.changed_member_id
           FROM v_members_expiring
          WHERE v_members_expiring.group_name::text = 'pending_cancellations'::text));


-- public.v_payment_history source

CREATE OR REPLACE VIEW public.v_payment_history
AS SELECT p.member_id,
    m.fname,
    m.lname,
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 10::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-10",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 9::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-09",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 8::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-08",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 7::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-07",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 6::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-06",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 5::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-05",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 4::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-04",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 3::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-03",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 2::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-02",
    max(
        CASE
            WHEN date_part('year'::text, p.payment_date) = 2024::double precision AND date_part('month'::text, p.payment_date) = 1::double precision THEN p.payment_date
            ELSE NULL::timestamp with time zone
        END) AS "2024-01"
   FROM payment p
     LEFT JOIN members m ON p.member_id = m.member_id
  WHERE p.payment_date >= '2024-01-01 00:00:00-05'::timestamp with time zone
  GROUP BY p.member_id, m.fname, m.lname;


-- public.v_storage_audit source

CREATE OR REPLACE VIEW public.v_storage_audit
AS WITH last_access AS (
         SELECT access_log.member_id,
            max(access_log.access_time) AS last_access_time
           FROM access_log
          GROUP BY access_log.member_id
        ), member_status AS (
         SELECT m.member_id,
            mg.mgroup_id
           FROM members m
             LEFT JOIN member_mgroup mg ON m.member_id = mg.member_id AND mg.mgroup_id = (( SELECT mgroup.mgroup_id
                   FROM mgroup
                  WHERE mgroup.name::text = 'members'::text))
        ), raw AS (
         SELECT ss.name AS slot_name,
            sl.name AS slot_location,
            la.last_access_time,
            ms.mgroup_id AS is_member,
            m.fname,
            m.lname,
            m.email,
            m.paypal_email,
            m.phone
           FROM storage_slot ss
             LEFT JOIN storage_location sl ON ss.location_id = sl.location_id
             LEFT JOIN last_access la ON ss.member_id = la.member_id
             LEFT JOIN member_status ms ON ss.member_id = ms.member_id
             LEFT JOIN members m ON ss.member_id = m.member_id
        )
 SELECT (split_part(raw.slot_name::text, '-'::text, 1) || '-'::text) || lpad(split_part(raw.slot_name::text, '-'::text, 2), 2, '0'::text) AS slot_name,
    raw.slot_location,
    raw.last_access_time::date AS last_access,
        CASE
            WHEN raw.is_member IS NOT NULL AND raw.fname IS NOT NULL THEN 'yes'::text
            WHEN raw.is_member IS NULL AND raw.fname IS NOT NULL THEN 'no'::text
            ELSE ''::text
        END AS is_member,
    raw.fname,
    raw.lname,
    raw.email,
    raw.paypal_email,
    raw.phone
   FROM raw
  ORDER BY ((split_part(raw.slot_name::text, '-'::text, 1) || '-'::text) || lpad(split_part(raw.slot_name::text, '-'::text, 2), 2, '0'::text));



